import { test as base } from '@playwright/test';

export const test = base.extend<{ forEachTest: void }>({
  forEachTest: [async ({ page }, use) => {
    await page.goto('/user/login');
    await page.getByRole('textbox', { name: 'Username' }).fill('recipe_user');
    await page.getByRole('textbox', { name: 'Password' }).fill('password');
    await page.getByRole('button', { name: 'Log in' }).click();
    await use();
  }, { auto: true }],  // automatically starts for every test.
});
