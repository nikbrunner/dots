(function() {
  const WS_URL = 'ws://' + window.location.host;
  let ws = null;
  let eventQueue = [];

  // --- Per-option feedback storage ---
  const feedbackMap = new Map();
  let currentChoice = null;

  function connect() {
    ws = new WebSocket(WS_URL);

    ws.onopen = () => {
      eventQueue.forEach(e => ws.send(JSON.stringify(e)));
      eventQueue = [];
    };

    ws.onmessage = (msg) => {
      const data = JSON.parse(msg.data);
      if (data.type === 'reload') {
        window.location.reload();
      }
    };

    ws.onclose = () => {
      setTimeout(connect, 1000);
    };
  }

  function sendEvent(event) {
    event.timestamp = Date.now();
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(event));
    } else {
      eventQueue.push(event);
    }
  }

  // --- V2: Sidebar + Toggle Logic ---

  let selectedChoice = null;

  function initV2() {
    const options = document.querySelectorAll('.option[data-choice]');
    const toggle = document.getElementById('vc-toggle');
    const dialog = document.getElementById('vc-dialog');
    const island = document.getElementById('vc-island');

    if (!options.length || !toggle || !dialog) return;

    // Show the floating toggle button + island
    toggle.style.display = 'block';
    if (island) island.style.display = 'flex';

    // Toggle dialog open/close
    toggle.addEventListener('click', () => {
      const isOpen = dialog.classList.toggle('open');
      toggle.classList.toggle('active', isOpen);
    });

    // IntersectionObserver: track which option is visible
    const observer = new IntersectionObserver((entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          const option = entry.target;
          const choice = option.dataset.choice;

          // Save current feedback before switching
          saveFeedback();

          currentChoice = choice;
          updateSidebarMetadata(option);
          restoreFeedback(choice);
          updateIsland();

          // Update select button state based on whether current option is the selected one
          const selectBtn = document.getElementById('vc-select');
          if (selectBtn) {
            if (selectedChoice === choice) {
              selectBtn.textContent = 'Selected \u2714';
              selectBtn.style.background = 'var(--success)';
            } else {
              selectBtn.textContent = 'Select';
              selectBtn.style.background = '';
            }
          }
        }
      }
    }, { threshold: 0.5 });

    options.forEach(option => observer.observe(option));

    // Initialize with first option
    if (options[0]) {
      currentChoice = options[0].dataset.choice;
      updateSidebarMetadata(options[0]);
    }

    // Select button
    const selectBtn = document.getElementById('vc-select');
    if (selectBtn) {
      selectBtn.addEventListener('click', () => {
        if (!currentChoice) return;

        // Save feedback text
        saveFeedback();
        const feedbackText = feedbackMap.get(currentChoice) || '';

        // Remove selected from all, add to current
        options.forEach(o => o.classList.remove('selected'));
        const current = document.querySelector(`.option[data-choice="${currentChoice}"]`);
        if (current) current.classList.add('selected');

        // Build event
        const event = {
          type: 'click',
          choice: currentChoice,
          text: current ? current.dataset.title || currentChoice : currentChoice,
          id: current ? current.id || null : null
        };
        if (feedbackText) event.feedback = feedbackText;

        sendEvent(event);

        // Also POST to /api/select as HTTP fallback (resolves decision promise server-side)
        fetch('/api/select', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(event)
        }).catch(function() {
          // WebSocket is primary; HTTP is a best-effort fallback
        });

        // Track selection
        selectedChoice = currentChoice;
        updateIsland();

        // Update Select button to confirmed state
        selectBtn.textContent = 'Selected \u2714';
        selectBtn.style.background = 'var(--success)';

        // Show auto-close overlay (Plannotator-style)
        showSelectionOverlay(current ? current.dataset.title || currentChoice : currentChoice);

      });
    }
  }

  function showSelectionOverlay(selectedTitle) {
    var overlay = document.createElement('div');
    overlay.id = 'vc-selection-overlay';
    overlay.className = 'vc-overlay';
    overlay.innerHTML =
      '<div class="vc-overlay-bg"></div>' +
      '<div class="vc-overlay-inner">' +
        '<div class="vc-overlay-icon">' +
          '<svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>' +
        '</div>' +
        '<h2 class="vc-overlay-title">Selected</h2>' +
        '<p class="vc-overlay-subtitle">' + escapeHtml(selectedTitle) + '</p>' +
        '<p class="vc-overlay-status" id="vc-close-status">Closing in 3s...</p>' +
      '</div>';
    document.body.appendChild(overlay);

    function tryClose(callback) {
      window.close();
      setTimeout(function() {
        if (!window.closed) {
          callback();
        }
      }, 300);
    }

    // Countdown: 3... 2... 1... close
    var remaining = 3;
    var statusEl = document.getElementById('vc-close-status');
    var timer = setInterval(function() {
      remaining--;
      if (remaining > 0) {
        if (statusEl) statusEl.textContent = 'Closing in ' + remaining + 's...';
      } else {
        clearInterval(timer);
        if (statusEl) statusEl.textContent = '';
        tryClose(function() {
          if (statusEl) {
            statusEl.innerHTML = '';
          }
          // Add a visible close button
          var closeBtn = document.createElement('button');
          closeBtn.textContent = 'Close Tab';
          closeBtn.className = 'vc-overlay-btn';
          closeBtn.onclick = function() { try { window.close(); } catch(e) {} };
          overlay.querySelector('.vc-overlay-inner').appendChild(closeBtn);
        });
      }
    }, 1000);
  }

  function escapeHtml(str) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  function updateIsland() {
    const island = document.getElementById('vc-island');
    const selText = document.getElementById('vc-island-selection-text');
    if (!island || !selText) return;

    if (selectedChoice && currentChoice === selectedChoice) {
      const selOption = document.querySelector(`.option[data-choice="${selectedChoice}"]`);
      const title = selOption?.dataset.title || selectedChoice;
      selText.textContent = '\u2714 ' + title;
      island.classList.add('has-selection');
    } else {
      island.classList.remove('has-selection');
    }
  }

  function updateSidebarMetadata(option) {
    const letter = document.getElementById('vc-letter');
    const title = document.getElementById('vc-title');
    const desc = document.getElementById('vc-description');

    if (letter) letter.textContent = option.dataset.choice || '?';
    if (title) title.textContent = option.dataset.title || 'Option ' + (option.dataset.choice || '');
    if (desc) desc.textContent = option.dataset.description || '';
  }

  function saveFeedback() {
    if (!currentChoice) return;
    const textarea = document.getElementById('vc-feedback');
    if (textarea) {
      feedbackMap.set(currentChoice, textarea.value);
    }
  }

  function restoreFeedback(choice) {
    const textarea = document.getElementById('vc-feedback');
    if (textarea) {
      textarea.value = feedbackMap.get(choice) || '';
    }
  }

  // --- Legacy: Click selection for .cards and non-v2 .options ---

  document.addEventListener('click', (e) => {
    const target = e.target.closest('[data-choice]');
    if (!target) return;

    // Skip if inside v2 options (handled by sidebar Select button)
    if (target.closest('.options') && document.querySelector('.option[data-choice]')) return;

    sendEvent({
      type: 'click',
      text: target.textContent.trim(),
      choice: target.dataset.choice,
      id: target.id || null
    });

    // Update indicator bar
    setTimeout(() => {
      const indicator = document.getElementById('indicator-text');
      if (!indicator) return;
      const container = target.closest('.cards');
      const selected = container ? container.querySelectorAll('.selected') : [];
      if (selected.length === 0) {
        indicator.textContent = 'Click an option above, then return to the terminal';
      } else if (selected.length === 1) {
        const label = selected[0].querySelector('h3, .card-body h3')?.textContent?.trim() || selected[0].dataset.choice;
        indicator.innerHTML = '<span class="selected-text">' + label + ' selected</span> — return to terminal to continue';
      } else {
        indicator.innerHTML = '<span class="selected-text">' + selected.length + ' selected</span> — return to terminal to continue';
      }
    }, 0);
  });

  // Legacy: toggleSelect for old onclick handlers
  window.toggleSelect = function(el) {
    const container = el.closest('.options') || el.closest('.cards');
    const multi = container && container.dataset.multiselect !== undefined;
    if (container && !multi) {
      container.querySelectorAll('.option, .card').forEach(o => o.classList.remove('selected'));
    }
    if (multi) {
      el.classList.toggle('selected');
    } else {
      el.classList.add('selected');
    }
    window.selectedChoice = el.dataset.choice;
  };

  // Expose API
  window.selectedChoice = null;
  window.brainstorm = {
    send: sendEvent,
    choice: (value, metadata = {}) => sendEvent({ type: 'choice', value, ...metadata })
  };

  // Init
  connect();

  // Wait for DOM to be ready for v2 init
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initV2);
  } else {
    initV2();
  }
})();
