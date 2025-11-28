// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('turbo:load', function() {
    const editBtn = document.querySelector('.footer-edit-btn');
    const editModal = document.getElementById('edit-modal');
    const subjectModal = document.getElementById('subject-modal');
    const closeButtons = document.querySelectorAll('.close');
  
    // 編集ボタンクリック
    if (editBtn) {
      editBtn.addEventListener('click', function(e) {
        e.preventDefault();
        const grade = this.dataset.grade;
        const weekOffset = this.dataset.weekOffset;
        
        fetch(`/timetables/edit_modal?grade=${grade}&week_offset=${weekOffset}`, {
          headers: {
            'Accept': 'text/html'
          }
        })
        .then(response => response.text())
        .then(html => {
          document.getElementById('modal-body').innerHTML = html;
          editModal.style.display = 'block';
          attachCellClickEvents();
        });
      });
    }
  
    // セルクリックイベント
    function attachCellClickEvents() {
      const cells = document.querySelectorAll('.editable-cell');
      cells.forEach(cell => {
        cell.addEventListener('click', function() {
          const timetableId = this.dataset.timetableId;
          const day = this.dataset.day;
          const period = this.dataset.period;
          const currentSubject = this.textContent.trim();
          
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
          alert('変更しました');
        }
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