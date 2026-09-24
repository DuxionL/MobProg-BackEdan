class HelpArticle {
  final String title;
  final String body;
  final bool starred;

  const HelpArticle(this.title, this.body, {this.starred = false});
}

class HelpSection {
  final String title;
  final List<HelpArticle> articles;

  const HelpSection(this.title, this.articles);
}

const String _soon = 'This guide will be available in a future update.';

const List<HelpSection> helpSections = [
  HelpSection("What's new", [
    HelpArticle(
      'Your settings are now saved',
      'Theme, currency, categories, passcode, and account settings are kept after you close the app.',
      starred: true,
    ),
    HelpArticle(
      'Accounts and account groups',
      'You can create your own account groups and accounts, and see them on the Accounts tab.',
      starred: true,
    ),
    HelpArticle(
      'App lock',
      'When a passcode is on, the app asks for it when you reopen the app, based on the Request Passcode time.',
    ),
  ]),
  HelpSection('Getting started', [
    HelpArticle('Home tab', _soon),
    HelpArticle('Stats Tab', _soon),
    HelpArticle(
      'How to add an income & expense',
      'Open the Trans. tab, tap the + button, choose Income or Expense, fill in the amount, category, and account, then tap Save.',
    ),
    HelpArticle(
      'How to record a transfer',
      'Tap the + button, choose Transfer, pick the From and To accounts, enter the amount, then tap Save.',
    ),
    HelpArticle('How to make a bookmark', _soon),
    HelpArticle('How to set up a repeat schedule & installment', _soon),
  ]),
  HelpSection('FAQs', [
    HelpArticle(
      'Can we sync between devices?',
      'Your data is stored on this device. Syncing between devices is not available yet.',
      starred: true,
    ),
    HelpArticle(
      'Ads still show up after purchasing the paid version',
      'There is no paid version yet, and ads are not part of this app.',
    ),
  ]),
  HelpSection('Accounts Management', [
    HelpArticle('How to hide accounts', _soon),
    HelpArticle(
      'How to register/hide/edit/delete accounts',
      'Go to More > Accounts > Accounts Setting. Tap + to add an account, tap an account to edit it, and use the trash icon on the edit page to delete it. Deleted accounts can be restored from Deleted accounts.',
    ),
    HelpArticle(
      'How to set up Savings/Investment/Insurance/Loan as an expense',
      'Open More > Accounts > Transfer-Expense setting and tick the accounts that should count as expenses when you transfer money into them.',
    ),
    HelpArticle(
      'How to add loans & overdrafts',
      'Create an account in the Loan or Overdrafts group from Accounts Setting.',
    ),
    HelpArticle(
      'How to exclude balance of certain accounts from totals',
      _soon,
    ),
    HelpArticle(
      'How to manage account group',
      'Open More > Accounts > Account Group. Tap + to add a group, the pencil to edit it, the red button to delete it, and drag the handle to reorder.',
    ),
  ]),
  HelpSection('Category', [
    HelpArticle(
      'How to enable sub-category',
      'Open Income Category or Expense Category and turn on the Subcategory switch.',
    ),
    HelpArticle(
      'How to add a subcategory under main category',
      'Open a category page, tap the pencil next to a category, type a name under Subcategories, then tap Save.',
    ),
    HelpArticle(
      'How to change subcategory to main category',
      'Remove it from the subcategory list of its main category, then add it again as a new category with the + button.',
    ),
  ]),
  HelpSection('Card Management', [
    HelpArticle(
      'How to add debit & credit card accounts',
      'Create a group with the credit or debit card type in Account Group, then add accounts to it from Accounts Setting.',
    ),
    HelpArticle('How to settle credit card payments', _soon),
    HelpArticle('How to change credit card payment date', _soon),
    HelpArticle('How to use debit cards', _soon),
    HelpArticle(
      'How to display credit card usage amount',
      'Open More > Accounts > Card expenses display config and choose A. At the time or B. Lump sum.',
    ),
    HelpArticle('How to track rebates and cashflows', _soon),
  ]),
  HelpSection('Backup & Restore', [
    HelpArticle('How to backup and restore data', _soon),
    HelpArticle('How to set automatic backup feature', _soon),
    HelpArticle('How to transfer data to the new phone', _soon),
    HelpArticle('How to import bulk data by Excel file', _soon),
  ]),
  HelpSection('PC Management', [HelpArticle('How to use PC Manager', _soon)]),
  HelpSection('Other Features', [
    HelpArticle(
      'How to set style',
      'Open More > Configuration > Style and choose System, Dark, or Light mode.',
    ),
    HelpArticle(
      'How to change the main currency',
      'Open More > Configuration > Main Currency Setting, pick a currency, adjust the unit position and decimal point, then tap Save.',
    ),
    HelpArticle('How to edit and delete Repeat Setting', _soon),
    HelpArticle(
      'How to change the start screen to Daily or Calendar',
      'Open More > Configuration > Start Screen and pick the screen you want.',
    ),
    HelpArticle('How to assign color to notes', _soon),
    HelpArticle(
      'How to activate the note button',
      'Turn on Note button setting in More > Configuration.',
    ),
    HelpArticle('How to use filter', _soon),
    HelpArticle('How to insert receipts or photos', _soon),
    HelpArticle(
      'How to set up autocomplete',
      'Turn Autocomplete on or off in More > Configuration.',
    ),
    HelpArticle(
      'How to use passcode',
      'Open More > Passcode and create a 4-digit passcode. Then choose how soon the app asks for it in Request Passcode.',
    ),
    HelpArticle(
      'How to customize monthly & weekly period',
      'In More > Configuration, set Monthly Start Date and Weekly Start Day.',
    ),
    HelpArticle(
      'How to change income & expense colors',
      'In More > Configuration, choose Income-Expenses Color Setting.',
    ),
    HelpArticle('How to set up a reminding alarm', _soon),
    HelpArticle('How to add time input', _soon),
    HelpArticle('How to change the language', _soon),
    HelpArticle('How to add sub-currencies', _soon),
  ]),
];
