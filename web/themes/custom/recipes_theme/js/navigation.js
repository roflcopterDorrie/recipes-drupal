
(function (Drupal, once) {

  Drupal.behaviors.recipesNavigation = {
    attach: function (context) {

      const recipesMobileNavToggle = once('allErecipesMobileNavToggleditFrequencies', '.recipes-menu-toggle', context);

      recipesMobileNavToggle.forEach(async function () {

        const button = document.querySelector('.recipes-menu-toggle');
        console.log(button);
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
