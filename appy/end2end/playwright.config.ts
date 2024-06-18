import type { PlaywrightTestConfig } from '@playwright/test';
import { devices } from '@playwright/test';

const SERVER = `http://127.0.0.1:8080`;

const config: PlaywrightTestConfig = {
  testDir: './tests',
  // Maximum time one test can run for.
  timeout: 30 * 1000,
  expect: {
    /**
     * Maximum time expect() should wait for the condition to be met.
     * For example in `await expect(locator).toHaveText();`
     */
    timeout: 5000,
  },
  // Run tests in files in parallel.
  fullyParallel: true,
  // Fail the build on CI if you accidentally left test.only in the source code.
  forbidOnly: !!process.env.CI,
  // Retry on CI only.
  retries: process.env.CI ? 2 : 0,
  // [Optional] Opt out of parallel tests on CI.
  // workers: process.env.CI ? 1 : undefined,
  // Limit the number of failures on CI to save resources
  maxFailures: process.env.CI ? 10 : undefined,

  reporter: 'html',
  use: {
    // Base URL to use in actions like `await page.goto('/')`.
    baseURL: SERVER,
    // Maximum time each action such as `click()` can take. Defaults to 0 (no limit).
    actionTimeout: 0,
    // Collect trace when retrying the failed test.
    trace: 'on-first-retry',
  },

  // Configure which browsers to test against.
  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
      },
    },
  ],
  webServer: {
    command: 'just dev ui-internal',
    // Set a timeout of 10 minutes.
    timeout: 10 * 60 * 1000,
    url: SERVER,
    reuseExistingServer: true,
    stdout: 'ignore',
    stderr: 'pipe',
  },
};

export default config;
