import { test, expect } from '@playwright/test';

test('redirects to login', async ({ page }) => {
  await page.goto('/');

  // Expect a title "to contain" a substring.
  await expect(page).toHaveURL(new URLPattern({ pathname: '/user/login' }));
});

