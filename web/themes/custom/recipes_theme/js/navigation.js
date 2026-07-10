
(function (Drupal, once) {

  Drupal.behaviors.recipesNavigation = {
    attach: function (context) {

      const recipesMobileNavToggle = once('recipesMobileNavToggle', '.recipes-nav', context);

      recipesMobileNavToggle.forEach(async function () {

        const button = context.querySelector('.recipes-menu-toggle');
        const items = context.querySelector('.recipes-nav');
        if (!button)
          return;
        
        button.addEventListener('click', () => {
          const isOpen = items.classList.toggle('open');

          // update accessibility state
          button.setAttribute('aria-expanded', isOpen);
        });

      });

      // Move the H1 title into the nav.
      const recipesMoveTitle = once('recipesMoveTitle', '.recipes-nav', context);

      recipesMoveTitle.forEach(async function () {
        const h1Title = document.querySelector('h1');
        const navTitleContainer = context.querySelector('.recipes-nav .page-title');
        h1Title.classList.remove('visually-hidden');
        navTitleContainer.append(h1Title);

        if (drupalSettings.recipes?.recipe_page_full) {
          h1Title.textContent = 'Recipe';
        }
      });

    }
  };

})(Drupal, once);
