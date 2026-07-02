# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: recipes.spec.ts >> Add a recipe to my list
- Location: tests/recipes.spec.ts:25:5

# Error details

```
Error: expect(locator).toContainText(expected) failed

Locator: locator('h1')
Expected substring: "Indian Pumpkin Curry"
Timeout: 5000ms
Error: element(s) not found

Call log:
  - Expect "toContainText" with timeout 5000ms
  - waiting for locator('h1')

```

```yaml
- link "Skip to main content":
  - /url: "#main-content"
- main:
  - heading "Primary tabs" [level=2]
  - list:
    - listitem:
      - link "Log in":
        - /url: /user/login
    - listitem:
      - link "Reset your password":
        - /url: /user/password
  - text: Username
  - textbox "Username"
  - text: Password
  - textbox "Password"
  - button "Log in"
```

# Test source

```ts
  1  | import { test, expect } from '@playwright/test';
  2  | 
  3  | test('Not logged in redirects to login', async ({ page }) => {
  4  |   await page.goto('/');
  5  |   await expect(page).toHaveURL(new URLPattern({ pathname: '/user/login' }));
  6  |   await expect(page).toHaveScreenshot();
  7  | });
  8  | 
  9  | test('Login', async ({ page }) => {
  10 |   // Login.
  11 |   await page.goto('/');
  12 |   await page.getByRole('textbox', { name: 'Username' }).fill('recipe_user');
  13 |   await page.getByRole('textbox', { name: 'Password' }).fill('password');
  14 |   await page.getByRole('button', { name: 'Log in' }).click();
  15 | 
  16 |   // User should see the menu links.
  17 |   await expect(page.getByRole('list')).toContainText('Browse recipes');
  18 |   await expect(page.getByRole('list')).toContainText('Quick create');
  19 |   await expect(page.getByRole('list')).toContainText('My list');
  20 |   await expect(page.getByRole('list')).toContainText('Shopping list');
  21 | 
  22 |   await expect(page).toHaveScreenshot();
  23 | });
  24 | 
  25 | test('Add a recipe to my list', async ({ page }) => {
  26 |   // Browse recipes.
  27 |   await page.goto('/recipes/indian-pumpkin-curry');
  28 | 
  29 |   // User should see the recipe.
> 30 |   await expect(page.locator('h1')).toContainText('Indian Pumpkin Curry')
     |                                    ^ Error: expect(locator).toContainText(expected) failed
  31 | 
  32 |   // Click the add to list button.
  33 |   await page.locator('a[data-button-id="recipes-add-to-list-button"]').click();
  34 | 
  35 |   // Status message.
  36 |   await expect(page.getByLabel('Status message')).toContainText('Status message Recipe added.');
  37 | 
  38 |   await expect(page).toHaveScreenshot();
  39 | });
  40 | /*
  41 | test('Create a shopping list', async ({ page }) => {
  42 |   // Go to my list.
  43 |   await page.goto('/recipes/my-list');
  44 | 
  45 |   // Recipe should be available.
  46 |   await expect(page.getByRole('link', { name: 'Food Indian Pumpkin Curry' })).toBeVisible();
  47 | 
  48 |   // Click make shopping list.
  49 |   await page.getByRole('link', { name: 'Make shopping list' }).click();
  50 | 
  51 |   // Remove carrot.
  52 |   await page.locator('label').filter({ hasText: '- carrot - 1 cup (150 g) (chopped)' }).click();
  53 | 
  54 |   // Generate the shopping list.
  55 |   await page.getByRole('button', { name: 'Make shopping list' }).click();
  56 | 
  57 |   // Make sure carrot isn't there.
  58 |   await expect(page.locator('label').filter({ hasText: '- carrot - 1 cup (150 g) (chopped)' })).not.toBeAttached();
  59 | 
  60 |   await expect(page).toHaveScreenshot();
  61 | });
  62 | 
  63 | test('Add custom ingredients to shopping list', async ({ page }) => {
  64 |   // Go to my list.
  65 |   await page.goto('/recipes/shopping-list');
  66 | 
  67 |   await page.getByRole('textbox', { name: 'Extra' }).click();
  68 |   await page.getByRole('textbox', { name: 'Extra' }).fill('Tomato sauce\nSoy milk\n\nAvocado');
  69 |   await page.getByRole('button', { name: 'Save' }).click();
  70 | 
  71 |   // Make sure Custom list is visible.
  72 |   await expect(page.locator('fieldset legend').filter({ hasText: 'Custom'})).toBeVisible();
  73 | 
  74 |   // Make sure there are exactly 3 ingredients under custom.
  75 |   await expect(page.locator('fieldset legend').filter({ hasText: 'Custom'}).locator('input')).toHaveCount(3);
  76 | });*/
```