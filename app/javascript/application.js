// app/javascript/application.js
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('turbo:load', function() {
    const editBtn = document.querySelector('.footer-edit-btn');
    const defaultBtn = document.querySelector('.footer-default-btn');
    const editModal = document.getElementById('edit-modal');
    const subjectModal = document.getElementById('subject-modal');
    const closeButtons = document.querySelectorAll('.close');
  
    // 編集ボタンクリック
    if (editBtn) {
      editBtn.addEventListener('click', function(e) {
        e.preventDefault();
        const grade = this.dataset.grade;
        const weekOffset = this.dataset.weekOffset;
        
        console.log('='.repeat(50));
        console.log('Edit button clicked');
        console.log('Grade:', grade);
        console.log('Week Offset:', weekOffset);
        console.log('URL:', `/timetables/edit_modal?grade=${grade}&week_offset=${weekOffset}`);
        console.log('='.repeat(50));
        
        fetch(`/timetables/edit_modal?grade=${grade}&week_offset=${weekOffset}`, {
          headers: {
            'Accept': 'text/html'
          }
        })
        .then(response => response.text())
        .then(html => {
          console.log('Modal content received');
          document.getElementById('modal-body').innerHTML = html;
          editModal.style.display = 'block';
          attachCellClickEvents();
        })
        .catch(error => {
          console.error('Error:', error);
        });
      });
    }

    // デフォルト時間割編集ボタン
    if (defaultBtn) {
      defaultBtn.addEventListener('click', function(e) {
        e.preventDefault();
        const grade = this.dataset.grade;
        
        console.log('Default button clicked, grade:', grade);
        
        // 最初は前期を表示
        loadDefaultTimetable(grade, 1);
      });
    }

    // デフォルト時間割を読み込む
    function loadDefaultTimetable(grade, semester) {
      fetch(`/timetables/edit_default_modal?grade=${grade}&semester=${semester}`, {
        headers: {
          'Accept': 'text/html'
        }
      })
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.text();
      })
      .then(html => {
        document.getElementById('modal-body').innerHTML = html;
        editModal.style.display = 'block';
        
        // タブの切り替えイベント
        attachSemesterTabs(grade);
        
        // セルのクリックイベント
        attachDefaultCellClickEvents();
      })
      .catch(error => {
        console.error('Error loading default timetable:', error);
        alert('デフォルト時間割の読み込みに失敗しました');
      });
    }

    // 学期タブの切り替え
    function attachSemesterTabs(grade) {
      const tabs = document.querySelectorAll('.semester-tab');
      tabs.forEach(tab => {
        tab.addEventListener('click', function() {
          const semester = parseInt(this.dataset.semester);
          
          // タブのアクティブ状態を切り替え
          tabs.forEach(t => t.classList.remove('active'));
          this.classList.add('active');
          
          // 時間割を読み込む
          loadDefaultTimetableTable(grade, semester);
        });
      });
      
      // 初期状態で前期をアクティブに
      if (tabs.length > 0) {
        tabs[0].classList.add('active');
        loadDefaultTimetableTable(grade, 1);
      }
    }

    // デフォルト時間割テーブルを読み込む
    function loadDefaultTimetableTable(grade, semester) {
      fetch(`/timetables/edit_default_modal?grade=${grade}&semester=${semester}`, {
        headers: {
          'Accept': 'text/html'
        }
      })
      .then(response => response.text())
      .then(html => {
        // テーブル部分だけを抽出して更新
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        const table = doc.querySelector('.edit-timetable');
        
        const container = document.getElementById('default-timetable-container');
        if (container && table) {
          container.innerHTML = table.outerHTML;
          attachDefaultCellClickEvents();
        }
      })
      .catch(error => {
        console.error('Error loading table:', error);
      });
    }

    // デフォルト時間割のセルクリックイベント
    function attachDefaultCellClickEvents() {
      const cells = document.querySelectorAll('.default-editable-cell');
      cells.forEach(cell => {
        cell.addEventListener('click', function() {
          const defaultTimetableId = this.dataset.defaultTimetableId;
          const currentSubject = this.textContent.trim();
          
          showDefaultSubjectModal(defaultTimetableId, currentSubject, this);
        });
      });
    }

    // デフォルト時間割の科目選択モーダル
    function showDefaultSubjectModal(defaultTimetableId, currentSubject, cellElement) {
      const subjectsData = JSON.parse(document.getElementById('default-all-subjects').dataset.subjects);
      
      let html = `
        <select id="default-subject-select" class="subject-select">
          <option value="">-</option>
          ${subjectsData.map(s => 
            `<option value="${s.id}" ${s.name === currentSubject ? 'selected' : ''}>${s.name}</option>`
          ).join('')}
        </select>
        <button id="update-default-subject-btn" class="update-btn">変更</button>
      `;
      
      document.getElementById('subject-modal-body').innerHTML = html;
      subjectModal.style.display = 'block';

      // 変更ボタンクリック
      document.getElementById('update-default-subject-btn').addEventListener('click', function() {
        const subjectId = document.getElementById('default-subject-select').value;
        updateDefaultSubject(defaultTimetableId, subjectId, cellElement);
      });
    }

    // デフォルト時間割の科目を更新
    function updateDefaultSubject(defaultTimetableId, subjectId, cellElement) {
      fetch(`/default_timetables/${defaultTimetableId}/update_subject`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ subject_id: subjectId })
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          cellElement.textContent = data.subject_name;
          subjectModal.style.display = 'none';
          // ページをリロードして変更を反映
          location.reload();
        }
      })
      .catch(error => {
        console.error('Update error:', error);
      });
    }
    // セルクリックイベント
    function attachCellClickEvents() {
      const cells = document.querySelectorAll('.editable-cell:not(.default-editable-cell)');
      console.log('Attaching click events to', cells.length, 'cells');
      
      cells.forEach(cell => {
        cell.addEventListener('click', function() {
          const timetableId = this.dataset.timetableId;
          const day = this.dataset.day;
          const period = this.dataset.period;
          const currentSubject = this.textContent.trim();
          
          console.log('Cell clicked - ID:', timetableId, 'Day:', day, 'Period:', period);
          
          showSubjectModal(timetableId, currentSubject, this, day, period);
        });
      });
    }
  
    // 科目選択モーダル表示
    function showSubjectModal(timetableId, currentSubject, cellElement, day, period) {
      const subjectsData = JSON.parse(document.getElementById('all-subjects').dataset.subjects);
      
      let html = `
        <select id="subject-select" class="subject-select">
          <option value="">-</option>
          ${subjectsData.map(s => 
            `<option value="${s.id}" ${s.name === currentSubject ? 'selected' : ''}>${s.name}</option>`
          ).join('')}
        </select>
        <div class="exam-checkbox">
          <label>
            <input type="checkbox" id="is-exam-checkbox"> 試験
          </label>
        </div>
        <button id="update-subject-btn" class="update-btn" data-timetable-id="${timetableId}">変更</button>
      `;
      
      document.getElementById('subject-modal-body').innerHTML = html;
      subjectModal.style.display = 'block';
  
      // 変更ボタンクリック
      document.getElementById('update-subject-btn').addEventListener('click', function() {
        const subjectId = document.getElementById('subject-select').value;
        const isExam = document.getElementById('is-exam-checkbox').checked;
        updateSubject(timetableId, subjectId, cellElement, day, period, isExam);
      });
    }
  
    // 科目更新
    function updateSubject(timetableId, subjectId, cellElement, day, period, isExam) {
      console.log('Updating timetable ID:', timetableId, 'with subject ID:', subjectId);
      
      fetch(`/timetables/${timetableId}/update_subject`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ 
          subject_id: subjectId,
          is_exam: isExam
        })
      })
      .then(response => response.json())
      .then(data => {
        console.log('Update response:', data);
        
        if (data.success) {
          // 【試験】プレフィックスを除去して表示
          const displayName = data.subject_name.replace("【試験】", "");
          
          // モーダル内のセルを更新
          cellElement.textContent = displayName;
          
          // クラスを更新
          cellElement.classList.remove('changed-cell', 'exam-cell');
          if (data.is_changed) {
            cellElement.classList.add('changed-cell');
          }
          if (data.is_exam) {
            cellElement.classList.add('exam-cell');
          }
          
          // メイン時間割のセルも更新
          updateMainTimetable(day, period, displayName, data.is_changed, data.is_exam);
          
          subjectModal.style.display = 'none';
        }
      })
      .catch(error => {
        console.error('Update error:', error);
      });
    }
  
    // メイン時間割を更新
    function updateMainTimetable(day, period, subjectName, isChanged, isExam) {
      const mainTable = document.querySelector('.timetable:not(.edit-timetable)');
      if (mainTable) {
        const tbody = mainTable.querySelector('tbody');
        const rows = tbody.querySelectorAll('tr');
        
        // period行目、day列目のセルを更新
        if (rows[period - 1]) {
          const cells = rows[period - 1].querySelectorAll('td');
          if (cells[day - 1]) {
            const cell = cells[day - 1];
            cell.textContent = subjectName;
            
            // クラスを更新
            cell.classList.remove('changed-cell', 'exam-cell');
            if (isChanged) {
              cell.classList.add('changed-cell');
            }
            if (isExam) {
              cell.classList.add('exam-cell');
            }
          }
        }
      }
    }
  
    // モーダルを閉じる
    closeButtons.forEach(btn => {
      btn.addEventListener('click', function() {
        editModal.style.display = 'none';
        subjectModal.style.display = 'none';
      });
    });
  
    // モーダル外クリックで閉じる
    window.addEventListener('click', function(e) {
      if (e.target === editModal) {
        editModal.style.display = 'none';
      }
      if (e.target === subjectModal) {
        subjectModal.style.display = 'none';
      }
    });
  });