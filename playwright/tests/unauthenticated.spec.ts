import { test, expect }  from '@playwright/test';

test('Not logged in redirects to login', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveURL(new URLPattern({ pathname: '/user/login' }));
  await expect(page).toHaveScreenshot();
});
