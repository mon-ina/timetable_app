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
          // モーダル内のセルを更新
          cellElement.textContent = data.subject_name;
          
          // 科目選択モーダルだけを閉じる（編集モーダルは開いたまま）
          subjectModal.style.display = 'none';
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
        // デフォルト時間割編集モーダルが開いているか確認
        const isDefaultModal = document.querySelector('.semester-tabs') !== null;
        
        editModal.style.display = 'none';
        subjectModal.style.display = 'none';
        
        // デフォルト時間割編集モーダルを閉じたらリロード
        if (isDefaultModal) {
          location.reload();
        }
      });
    });
  
    // モーダル外クリックで閉じる
    window.addEventListener('click', function(e) {
      if (e.target === editModal) {
        // デフォルト時間割編集モーダルが開いているか確認
        const isDefaultModal = document.querySelector('.semester-tabs') !== null;
        
        editModal.style.display = 'none';
        
        // デフォルト時間割編集モーダルを閉じたらリロード
        if (isDefaultModal) {
          location.reload();
        }
      }
      if (e.target === subjectModal) {
        subjectModal.style.display = 'none';
      }
    });
  });

  document.addEventListener('turbo:load', function() {
  const messageIcon = document.getElementById('message-icon');
  const announcementsModal = document.getElementById('announcements-modal');
  const announcementDetailModal = document.getElementById('announcement-detail-modal');
  const createAnnouncementModal = document.getElementById('create-announcement-modal');
  
  const announcementsClose = document.querySelector('.announcements-close');
  const announcementDetailClose = document.querySelector('.announcement-detail-close');
  const createAnnouncementClose = document.querySelector('.create-announcement-close');
  
  const currentGrade = parseInt(document.querySelector('.grade-switch a.active')?.textContent) || 1;
  const isTeacher = document.querySelector('.login-role-label.teacher') !== null;
  
  // メッセージアイコンクリック
  if (messageIcon) {
    messageIcon.addEventListener('click', function() {
      loadAnnouncements();
    });
  }
  
  // お知らせ一覧を読み込む
  function loadAnnouncements() {
    fetch(`/announcements?grade=${currentGrade}`)
      .then(response => response.json())
      .then(data => {
        displayAnnouncementsList(data.announcements);
        announcementsModal.style.display = 'block';
      })
      .catch(error => {
        console.error('Error loading announcements:', error);
      });
  }
  
  // お知らせ一覧を表示
  function displayAnnouncementsList(announcements) {
    let html = '<h2>お知らせ</h2>';
    
    // 教員の場合は新規作成ボタンを表示
    if (isTeacher) {
      html += '<button class="create-announcement-btn" id="show-create-form-btn">新しいお知らせを作成</button>';
    }
    
    if (announcements.length === 0) {
      html += '<div class="empty-announcements">お知らせはありません</div>';
    } else {
      html += '<div class="announcement-list">';
      announcements.forEach(announcement => {
        const unreadClass = !announcement.is_read ? 'unread' : '';
        const unreadIndicator = !announcement.is_read ? '<span class="unread-indicator"></span>' : '';
        
        html += `
          <div class="announcement-item ${unreadClass}" data-id="${announcement.id}">
            <div class="announcement-item-content">
              <div class="announcement-title">${escapeHtml(announcement.title)}</div>
              <div class="announcement-date">${announcement.published_at}</div>
            </div>
            ${unreadIndicator}
          </div>
        `;
      });
      html += '</div>';
    }
    
    document.getElementById('announcements-modal-body').innerHTML = html;
    
    // お知らせアイテムのクリックイベント
    document.querySelectorAll('.announcement-item').forEach(item => {
      item.addEventListener('click', function() {
        const announcementId = this.dataset.id;
        const announcement = announcements.find(a => a.id == announcementId);
        showAnnouncementDetail(announcement);
      });
    });
    
    // 新規作成ボタンのクリックイベント
    const showCreateBtn = document.getElementById('show-create-form-btn');
    if (showCreateBtn) {
      showCreateBtn.addEventListener('click', function() {
        announcementsModal.style.display = 'none';
        createAnnouncementModal.style.display = 'block';
        
        // フォームの学年をセット
        document.getElementById('announcement-grade').value = currentGrade;
      });
    }
  }
  
  // お知らせ詳細を表示
  function showAnnouncementDetail(announcement) {
    const html = `
      <div class="announcement-detail-header">
        <h2 class="announcement-detail-title">${escapeHtml(announcement.title)}</h2>
        <div class="announcement-detail-date">${announcement.published_at}</div>
      </div>
      <div class="announcement-detail-content">${escapeHtml(announcement.content)}</div>
      <button class="back-to-list-btn" id="back-to-list-btn">一覧に戻る</button>
    `;
    
    document.getElementById('announcement-detail-body').innerHTML = html;
    
    // 既読にする
    if (!announcement.is_read && !isTeacher) {
      markAsRead(announcement.id);
    }
    
    // モーダル切り替え
    announcementsModal.style.display = 'none';
    announcementDetailModal.style.display = 'block';
    
    // 戻るボタン
    document.getElementById('back-to-list-btn').addEventListener('click', function() {
      // 先に一覧を読み込んでから切り替え
      fetch(`/announcements?grade=${currentGrade}`)
        .then(response => response.json())
        .then(data => {
          displayAnnouncementsList(data.announcements);
          announcementDetailModal.style.display = 'none';
          announcementsModal.style.display = 'block';
        })
        .catch(error => {
          console.error('Error loading announcements:', error);
          announcementDetailModal.style.display = 'none';
          announcementsModal.style.display = 'block';
        });
    });
  }
  
  // 既読にする
  function markAsRead(announcementId) {
    fetch(`/announcements/${announcementId}/mark_as_read`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        updateUnreadCount();
      }
    })
    .catch(error => {
      console.error('Error marking as read:', error);
    });
  }
  
  // お知らせ作成フォーム送信
  const createForm = document.getElementById('create-announcement-form');
  if (createForm) {
    createForm.addEventListener('submit', function(e) {
      e.preventDefault();
      
      const formData = {
        announcement: {
          grade: document.getElementById('announcement-grade').value,
          title: document.getElementById('announcement-title').value,
          content: document.getElementById('announcement-content').value
        }
      };
      
      fetch('/announcements', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify(formData)
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          
          // フォームをリセット
          createForm.reset();
          
          // 先に一覧を読み込んでから切り替え
          fetch(`/announcements?grade=${currentGrade}`)
            .then(response => response.json())
            .then(data => {
              displayAnnouncementsList(data.announcements);
              createAnnouncementModal.style.display = 'none';
              announcementsModal.style.display = 'block';
            })
            .catch(error => {
              console.error('Error loading announcements:', error);
              createAnnouncementModal.style.display = 'none';
            });
        } else {
          alert('エラー: ' + data.errors.join(', '));
        }
      })
      .catch(error => {
        console.error('Error creating announcement:', error);
        alert('お知らせの作成に失敗しました');
      });
    });
  }
  
  // キャンセルボタン
  const cancelCreateBtn = document.getElementById('cancel-create-btn');
  if (cancelCreateBtn) {
    cancelCreateBtn.addEventListener('click', function() {
      createAnnouncementModal.style.display = 'none';
      document.getElementById('create-announcement-form').reset();
    });
  }
  
  // モーダルを閉じる
  if (announcementsClose) {
    announcementsClose.addEventListener('click', function() {
      announcementsModal.style.display = 'none';
    });
  }
  
  if (announcementDetailClose) {
    announcementDetailClose.addEventListener('click', function() {
      announcementDetailModal.style.display = 'none';
    });
  }
  
  if (createAnnouncementClose) {
    createAnnouncementClose.addEventListener('click', function() {
      createAnnouncementModal.style.display = 'none';
      document.getElementById('create-announcement-form').reset();
    });
  }
  
  // モーダル外クリックで閉じる
  window.addEventListener('click', function(e) {
    if (e.target === announcementsModal) {
      announcementsModal.style.display = 'none';
    }
    if (e.target === announcementDetailModal) {
      announcementDetailModal.style.display = 'none';
    }
    if (e.target === createAnnouncementModal) {
      createAnnouncementModal.style.display = 'none';
      document.getElementById('create-announcement-form').reset();
    }
  });
  
  // HTMLエスケープ
  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
  
  // 未読件数を更新（グローバル関数として定義）
  window.updateUnreadCount = function() {
    const grade = currentGrade;
    fetch(`/announcements/unread_count?grade=${grade}`)
      .then(response => response.json())
      .then(data => {
        const badge = document.getElementById('unread-badge');
        if (data.unread_count > 0) {
          badge.textContent = data.unread_count;
          badge.style.display = 'flex';
        } else {
          badge.style.display = 'none';
        }
      })
      .catch(error => console.error('Error:', error));
  };
});