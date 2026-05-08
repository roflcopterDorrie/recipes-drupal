<?php

namespace Drupal\recipes\Form;

use Drupal\Core\DependencyInjection\DependencySerializationTrait;
use Drupal\Core\Form\FormBase;
use Drupal\Core\Form\FormStateInterface;
use Drupal\node\Entity\Node;
use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\recipes\Validation\RecipeDataValidator;
use Drupal\Core\Config\ImmutableConfig;
use Drupal\ai\Provider\ProviderPluginManager;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\ai\OperationType\Chat\ChatInput;
use Drupal\ai\OperationType\Chat\ChatMessage;
use Drupal\ai\AiProviderPluginManager;
use Drupal\ai\Plugin\ProviderProxy;
use Drupal\Core\Http\ClientFactory;
use DOMDocument;


/**
 * Implements an example form.
 */
class QuickCreate extends FormBase
{
  use DependencySerializationTrait;

  public function __construct(
    protected RecipeDataValidator $recipe_data_validator,
    protected ConfigFactoryInterface $config_factory,
    protected AiProviderPluginManager $ai_provider,
    protected EntityTypeManagerInterface $entity_type_manager,
    protected ClientFactory $httpClient,
    protected ?ImmutableConfig $config = NULL,
    protected ?ProviderProxy $ai_proxy_provider = NULL,
    protected ?string $ai_model_id = ''
  ) {
    $this->recipe_data_validator = $recipe_data_validator;
    $this->config_factory = $config_factory;
    $this->ai_provider = $ai_provider;
    $this->config = $this->config_factory->get('recipes.settings');
  }

  public static function create(ContainerInterface $container)
  {
    return new static(
      $container->get('recipes.recipe_data_validator'),
      $container->get('config.factory'),
      $container->get('ai.provider'),
      $container->get('entity_type.manager'),
      $container->get('http_client_factory')
    );
  }

  protected function chat(ChatInput $messages) {
    // Setup the AI model provider so we can use it.
    $ai_provider_settings = $this->ai_provider->getDefaultProviderForOperationType('chat');
    $ai_proxy_provider = $this->ai_provider->createInstance($ai_provider_settings['provider_id']);
    $ai_model_id = $ai_provider_settings['model_id'];
    return $ai_proxy_provider->chat($messages, $ai_model_id);
  }

  /**
   * {@inheritdoc}
   */
  public function getFormId()
  {
    return 'quick_create_form';
  }

  public function buildForm(array $form, FormStateInterface $form_state)
  {
    // Determine current step (default to 1)
    $step = $form_state->get('step') ?: 1;

    $form['#prefix'] = '<div id="recipe-form-wrapper">';
    $form['#suffix'] = '</div>';

    if ($step === 1) {

      $form['url'] = [
        '#type' => 'url',
        '#title' => $this->t('Recipe URL'),
        '#required' => TRUE,
      ];

      $form['actions']['extract'] = [
        '#type' => 'submit',
        '#value' => $this->t('Get Recipe'),
        //'#ajax' => [
        //  'callback' => '::ajaxStepCallback',
        //  'wrapper' => 'recipe-form-wrapper',
        //  'progress' => ['type' => 'throbber', 'message' => $this->t('Extracting data...')],
        //],
        '#submit' => ['::submitExtract'],
      ];
    } else if ($step === 2) {

      $extracted_recipe = $form_state->get('extracted_recipe');

      // Show a summary of ingredients (simplified)
      $form['previewRecipe'] = [
        '#markup' => json_encode($extracted_recipe),
      ];

      $form['actions']['save'] = [
        '#type' => 'submit',
        '#value' => $this->t('Save Recipe'),
        //'#ajax' => [
        //  'callback' => '::ajaxStepCallback',
        //  'wrapper' => 'recipe-form-wrapper',
        //],
        '#submit' => ['::submitSave'],
      ];

      /*$form['actions']['back'] = [
        '#type' => 'submit',
        '#value' => $this->t('Back'),
        '#submit' => ['::submitBack'],
        '#limit_validation_errors' => [],
        '#ajax' => ['callback' => '::ajaxStepCallback', 'wrapper' => 'recipe-form-wrapper'],
      ];*/
    }

    return $form;
  }


  public function submitExtract(array &$form, FormStateInterface $form_state)
  {

    $url = $form_state->getValue('url');

    $prompt = $this->config->get('prompt');

    $ingredientAisles = [];
    $ingredientAisleTerms = $this->entity_type_manager->getStorage('taxonomy_term')->loadByProperties(['vid' => 'recipes_ingredient_aisle']);
    foreach ($ingredientAisleTerms as $ingredientAisle) {
      $ingredientAisles[] = '- ' . $ingredientAisle->getName() . ': ' . $ingredientAisle->getDescription() . PHP_EOL;
    }

    try {
      $client = $this->httpClient->fromOptions();
      $response = $client->request('GET', $form_state->getValue('url'), [
        'timeout' => 10,
        'headers' => [
          'User-Agent' => 'Drupal Recipe Scraper/1.0',
        ],
      ]);

      $html = $response->getBody()->getContents();

      $dom = new DOMDocument();
      @$dom->loadHTML($html);

      $removeTags = ['script', 'style', 'noscript'];

      foreach ($removeTags as $tagName) {
        $nodes = $dom->getElementsByTagName($tagName);
        while ($nodes->length > 0) {
          $node = $nodes->item(0);
          $node->parentNode->removeChild($node);
        }
      }

      $body = $dom->getElementsByTagName('body')->item(0);
      $recipe_website_text = $body->nodeValue;

      $sanitisedPrompt = t($prompt, [
        '@website_text' => $recipe_website_text,
        '@ingredient_aisle_taxonomy' => implode(" ", $ingredientAisles),
        '@schema' => $this->recipe_data_validator->getSchema()
      ]);

      $messages = new ChatInput([
        new ChatMessage('user', $sanitisedPrompt->__toString()),
      ]);

      $response = $this->chat($messages);
      $return_message = $response->getNormalized();

      $recipe_text = $return_message->getText();

      //$recipe_text = '{ "title": "Vegan Shepherd\u2019s Pie with Gravy", "ingredients": [ { "amount": "3 lb.", "ingredient": "potatoes", "category": "Fresh Fruits and Vegetables", "extra": "(I used a bag of organic red potatoes), peeled and chopped" }, { "amount": "2 tbsp", "ingredient": "Earth Balance", "category": "Oils", "extra": "or equivalent" }, { "amount": "1/3 cup + 2 tbsp", "ingredient": "non-dairy milk", "category": "Plant based Milk", "extra": "(I used soy)" }, { "amount": "1 tsp", "ingredient": "kosher salt", "category": "Spices and Seasoning", "extra": "or to taste" }, { "amount": "to taste", "ingredient": "Freshly ground black pepper", "category": "Spices and Seasoning", "extra": null }, { "amount": "1/2 tsp", "ingredient": "garlic powder", "category": "Spices and Seasoning", "extra": null }, { "amount": "2 tbsp", "ingredient": "extra virgin olive oil", "category": "Oils", "extra": null }, { "amount": "1", "ingredient": "yellow onion", "category": "Fresh Fruits and Vegetables", "extra": "finely chopped" }, { "amount": "3 cloves", "ingredient": "garlic", "category": "Fresh Fruits and Vegetables", "extra": "minced" }, { "amount": "4 medium", "ingredient": "carrots", "category": "Fresh Fruits and Vegetables", "extra": "peeled & small dice" }, { "amount": "2", "ingredient": "parsnips", "category": "Fresh Fruits and Vegetables", "extra": "or other root vegetable, peeled & small dice" }, { "amount": "4", "ingredient": "celery stalks", "category": "Fresh Fruits and Vegetables", "extra": "small dice" }, { "amount": "1 cup", "ingredient": "full sodium vegetable broth", "category": "Stock", "extra": "(or more as needed)" }, { "amount": "1/4 cup", "ingredient": "red wine", "category": "Condiments", "extra": "(or more broth)" }, { "amount": "2 tsp", "ingredient": "dried thyme", "category": "Herbs", "extra": null }, { "amount": "1/2 tsp", "ingredient": "Italian seasoning", "category": "Spices and Seasoning", "extra": null }, { "amount": "1/2-3/4 tsp", "ingredient": "kosher salt", "category": "Spices and Seasoning", "extra": "to taste + black pepper" }, { "amount": "3 tbsp", "ingredient": "flour", "category": "Baking Ingredients", "extra": "(I used whole wheat)" }, { "amount": null, "ingredient": "paprika", "category": "Spices and Seasoning", "extra": "garnish" }, { "amount": null, "ingredient": "ground pepper", "category": "Spices and Seasoning", "extra": "garnish" }, { "amount": null, "ingredient": "Thyme", "category": "Herbs", "extra": "garnish" } ], "steps": [ "Preheat oven to 425\u00b0F and lightly oil a 2.5 quart/2.3 litre casserole dish.", "Place peeled and chopped potatoes into a large pot and add water, 2 inches above potatoes.", "Bring to a boil and then simmer on low for about 30 minutes until very tender.", "Meanwhile, prepare the vegetable filling.", "Chop the onion and mince the garlic and add to a skillet along with the oil.", "Cook on low for about 5-7 minutes.", "Now add in the chopped carrots, parsnip, and celery.", "Cook on medium-low heat for about 15 minutes.", "When the potatoes are done cooking, drain and add back to the pot.", "Add the Earth Balance (or butter), milk, and seasonings and mash well.", "Set aside.", "In a small bowl, whisk together the liquid ingredients (broth, red wine (optional), thyme, and flour).", "Add this liquid mixture to the vegetables in the skillet and stir well.", "Add your salt and pepper to taste.", "Cook for another 5-10 minutes or so until thickened.", "Season to taste.", "Scoop vegetable mixture into casserole dish.", "Spread on the mashed potato mixture and garnish with paprika, ground pepper, and Thyme.", "Bake at 425\u00b0F for about 35 minutes, or until golden and bubbly.", "Allow to cool for at least 10 minutes before serving." ] }';
      
      $extracted_recipe = $this->recipe_data_validator->extract($recipe_text);
      $result = $this->recipe_data_validator->validate($extracted_recipe, $this->recipe_data_validator->getSchema());
      if ($result->isValid()) {
        $form_state->set('extracted_recipe', $extracted_recipe);
        $form_state->set('step', 2);
      } else {
        $form_state->set('step', 1);

        foreach ($result->error()->subErrors() as $error) {
          $this->messenger()->addError(t('Validation error: @msg', ['@msg' => $error->message()]));
        }
      }
    } catch (\Exception $e) {
      $this->messenger()->addError($this->t('Could not fetch the URL: @error', ['@error' => $e->getMessage()]));
      return $form_state->setRebuild();
    }

    return $form_state->setRebuild();
  }


  public function submitSave(array &$form, FormStateInterface $form_state)
  {

    $recipe = $form_state->get('extracted_recipe');

    // Generate and save the Recipe.
    $recipeNode = Node::create([
      'type' => 'recipes_recipe',
      'title' => $recipe->title,
    ]);

    // Ingredients.
    $ingredientReferences = [];
    foreach ($recipe->ingredients as $ingredient) {
      $ingredientNode = Node::create([
        'type' => 'recipes_ingredient',
        'title' => $ingredient->ingredient,
        //'field_recipes_ingredient_name' => $ingredient->ingredient,
        'field_recipes_ingredient_amount' => $ingredient->amount,
        //'field_recipes_ingredient_extra' => $ingredient->extra,
      ]);

      $ingredientAisles = $this->entity_type_manager->getStorage('taxonomy_term')->loadByProperties([
        'name' => $ingredient->category,
        'vid' => 'recipes_ingredient_aisle',
      ]);
      if (!empty($ingredientAisles)) {
        $ingredientAisle = reset($ingredientAisles);
        $ingredientNode->set('field_recipes_ingredient_aisle', $ingredientAisle->id());
      }

      $ingredientNode->save();
      $ingredientReferences[] = ['target_id' => $ingredientNode->id()];
    }
    $recipeNode->set('field_recipes_ingredients', $ingredientReferences);

    // Steps.
    $recipeNode->set('field_recipes_steps', $recipe->steps);

    $recipeNode->save();

    $form_state->setRedirect('entity.node.canonical', ['node' => $recipeNode->id()]);
  }

  public function submitForm(array &$form, FormStateInterface $form_state) {}
}
