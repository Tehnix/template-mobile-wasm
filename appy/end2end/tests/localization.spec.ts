import { test, expect } from "@playwright/test";

test("localization translates text when changing language", async ({ page }) => {
  await page.goto("/");
  await expect(page.locator("h1")).toHaveText(
    "Welcome!"
  );

  await page.getByText('Go to fr').dblclick();
  await expect(page.locator("h1")).toHaveText(
    "Bienvenue!"
  );
});

test("localization loads correct text from URL", async ({ page }) => {
  await page.goto("/fr");
  await expect(page.locator("h1")).toHaveText(
    "Bienvenue!"
  );
});
