(function (Drupal, once) {

  Drupal.behaviors.recipesWakeLock = {
    attach: function (context) {
      if ('wakeLock' in navigator) {

        const recipesWakeLockToggle = once('recipesWakeLockToggle', '#recipes_wake_lock', context);

        recipesWakeLockToggle.forEach(async function () {

          (async () => {
            // The wake lock sentinel.
            let wakeLock = null;

            // Function that attempts to request a screen wake lock.
            const requestWakeLock = async () => {
              try {
                wakeLock = await navigator.wakeLock.request();
              } catch (err) {
                console.error(`${err.name}, ${err.message}`);
              }
            };

            const toggle = document.querySelector('#recipes_wake_lock');

            const handleToggleChange = async () => {
              if (toggle.checked) {
                await requestWakeLock();
              } else {
                wakeLock.release();
              }
            };

            toggle.addEventListener('change', handleToggleChange);

            const event = new InputEvent("change", {
              view: window,
              bubbles: true,
              cancelable: true,
            });

            toggle.dispatchEvent(event);

            const handleVisibilityChange = async () => {
              if (wakeLock !== null && document.visibilityState === 'visible') {
                await requestWakeLock();
              }
            };

            document.addEventListener('visibilitychange', handleVisibilityChange);
          })();
        });
      }
    }
  };

})(Drupal, once);
