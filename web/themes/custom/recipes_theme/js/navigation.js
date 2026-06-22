
(function (Drupal, once) {

  Drupal.behaviors.recipesNavigation = {
    attach: function (context) {

      once('recipesNavigation', context).forEach(async function () {

        const button = document.querySelector('.recipes-menu-toggle');
        const items = document.querySelector('.recipes-nav');
        if (!button)
          return;
        
        button.addEventListener('click', () => {
          const isOpen = items.classList.toggle('open');

          // update accessibility state
          button.setAttribute('aria-expanded', isOpen);
        });

      });
    }
  };

})(Drupal, once);
