import { test } from '../authenticated_fixtures';
import { expect } from '@playwright/test';

test('Add a recipe to my list', async ({ page }) => {
  // Browse recipes.
  await page.goto('/recipes/indian-pumpkin-curry');

  // User should see the recipe.
  await expect(page.locator('h1')).toContainText('Indian Pumpkin Curry')

  // Click the add to list button.
  await page.locator('a[data-button-id="recipes-add-to-list-button"]').click();

  // Status message.
  await expect(page.getByLabel('Status message')).toContainText('Status message Recipe added.');

  await expect(page).toHaveScreenshot();
});
/*
test('Create a shopping list', async ({ page }) => {
  // Go to my list.
  await page.goto('/recipes/my-list');

  // Recipe should be available.
  await expect(page.getByRole('link', { name: 'Food Indian Pumpkin Curry' })).toBeVisible();

  // Click make shopping list.
  await page.getByRole('link', { name: 'Make shopping list' }).click();

  // Remove carrot.
  await page.locator('label').filter({ hasText: '- carrot - 1 cup (150 g) (chopped)' }).click();

  // Generate the shopping list.
  await page.getByRole('button', { name: 'Make shopping list' }).click();

  // Make sure carrot isn't there.
  await expect(page.locator('label').filter({ hasText: '- carrot - 1 cup (150 g) (chopped)' })).not.toBeAttached();

  await expect(page).toHaveScreenshot();
});

test('Add custom ingredients to shopping list', async ({ page }) => {
  // Go to my list.
  await page.goto('/recipes/shopping-list');

  await page.getByRole('textbox', { name: 'Extra' }).click();
  await page.getByRole('textbox', { name: 'Extra' }).fill('Tomato sauce\nSoy milk\n\nAvocado');
  await page.getByRole('button', { name: 'Save' }).click();

  // Make sure Custom list is visible.
  await expect(page.locator('fieldset legend').filter({ hasText: 'Custom'})).toBeVisible();

  // Make sure there are exactly 3 ingredients under custom.
  await expect(page.locator('fieldset legend').filter({ hasText: 'Custom'}).locator('input')).toHaveCount(3);
});*/