<?php

namespace Drupal\recipes\Validation;

use Drupal\Core\Config\ConfigFactoryInterface;
use Opis\JsonSchema\ValidationResult;
use Drupal\Core\DependencyInjection\DependencySerializationTrait;

class RecipeDataValidator
{

  use DependencySerializationTrait;

  public function __construct(
    ConfigFactoryInterface $config_factory
  ) {}


  /**
   * Retrieves the contents of the specified JSON schema file.
   *
   * @param string $schema
   *   The filename of the schema to load. Defaults to 'recipe.schema.json'.
   *
   * @return string
   *   The raw contents of the schema file.
   */
  public function getSchema(string $schema = 'recipe.schema.json'): string
  {
    // Get the schema to test against.
    $modulePath = \Drupal::service('extension.list.module')->getPath('recipes');
    $schemaFile = $modulePath . '/schemas/' . $schema;
    return file_get_contents($schemaFile);
  }

  public function extract(string $extractedRecipeText, string $schema = 'recipe.schema.json'): object
  {
    // Get the schema to test against.
    $schemaData = json_decode($this->getSchema($schema));
    return json_decode($extractedRecipeText);
  }

  /**
   * Validates the structure of the AI-extracted recipe JSON.
   *
   * @param string $extractedRecipeText
   *   The raw JSON string to be validated.
   *
   * @return bool|object
   *   Returns the decoded object if valid, or FALSE if validation fails.
   */
  public function validate(object $dataToValidate, string $schemaData): ValidationResult
  {
    // Run the validation.
    $validator = new \Opis\JsonSchema\Validator();
    return $validator->validate($dataToValidate, $schemaData);
  }
}
