import { test, expect } from '@playwright/test';


test('redirects to login', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveURL(new URLPattern({ pathname: '/user/login' }));
  await expect(page).toHaveScreenshot();
});

test('login', async ({ page }) => {
  // Login.
  await page.goto('/');
  await page.getByRole('textbox', { name: 'Username' }).fill('recipe_user');
  await page.getByRole('textbox', { name: 'Password' }).fill('password');
  await page.getByRole('button', { name: 'Log in' }).click();

  // User should see the menu links.
  await expect(page.getByRole('list')).toContainText('Browse recipes');
  await expect(page.getByRole('list')).toContainText('Quick create');
  await expect(page.getByRole('list')).toContainText('My list');
  await expect(page.getByRole('list')).toContainText('Shopping list');

  await expect(page).toHaveScreenshot();
});