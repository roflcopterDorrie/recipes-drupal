
(function (Drupal, once) {

  Drupal.behaviors.recipesNavigation = {
    attach: function (context) {

      const recipesMobileNavToggle = once('recipesMobileNavToggle', '.recipes-navigation', context);

      recipesMobileNavToggle.forEach(async function () {

        const button = context.querySelector('.recipes-menu-toggle');
        const recipesNavigation = context.querySelector('.recipes-navigation');
        if (!button)
          return;
        
        button.addEventListener('click', () => {
          const isOpen = recipesNavigation.classList.toggle('open');

          // update accessibility state
          button.setAttribute('aria-expanded', isOpen);
        });

      });

    }
  };

})(Drupal, once);
