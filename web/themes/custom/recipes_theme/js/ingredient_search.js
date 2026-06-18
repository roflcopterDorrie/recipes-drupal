import Fuse from 'https://cdn.jsdelivr.net/npm/fuse.js@7.4.1/dist/fuse.basic.min.mjs';

(function (Drupal, once) {

  let ingredientCache = null;

  async function getIngredients() {
    if (ingredientCache !== null) {
      return ingredientCache;
    }

    const res = await fetch('/recipes/api/ingredients?_format=json');
    ingredientCache = await res.json();

    return ingredientCache;
  }

  Drupal.behaviors.recipesIngredientSearch = {
    attach: function (context) {
      once('recipesIngredientSearch', context).forEach(async function () {

        const ingredients = await getIngredients();

        const fuse = new Fuse(ingredients, {
          keys: ['title'],
          includeScore: true,
          threshold: 0.3,
          ignoreLocation: true,
        });

        const ingredientInput = document.querySelector('#recipes-ingredient-search');

        ingredientInput.addEventListener('input', debounce(function (event) {
          const term = event.target.value;
          if (!term) return;
          const results = fuse.search(term);
          renderResults(results);

          let ingredientIds = [];
          results.forEach(({ item }) => {
            ingredientIds.push(item.tid);
          });
          refreshViewWithIds(ingredientIds);
        }, 200)
        );

        function renderResults(results) {
          const ingredientResults = document.querySelector('#recipes-ingredient-search-results');
          const template = document.querySelector('#recipes-ingredient-template');

          ingredientResults.innerHTML = '';

          results.forEach(({ item }) => {
            const clone = template.content.cloneNode(true);

            clone.querySelector('.recipes-search-result__ingredient').textContent = item.title;

            ingredientResults.appendChild(clone);
          });
        }

        function refreshViewWithIds(ids) {
          const form = document.querySelector('.views-exposed-form');

          if (!form) return;

          const select = form.querySelector('select[name="tid[]"]');

          // Loop through each option and check if its value is in your array
          Array.from(select.options).forEach(option => {
            if (ids.includes(option.value)) {
              console.log("Selected: " + option.label + "("+option.value+")")
            }
            option.selected = ids.includes(option.value);
          });

          form.querySelector('[type="submit"]').click();
        }

        function debounce(fn, delay) {
          let timeout;
          return function (...args) {
            clearTimeout(timeout);
            timeout = setTimeout(() => fn.apply(this, args), delay);
          };
        }

      });
    }
  };

})(Drupal, once);
