import React, { useState } from 'react';

const FinanceApp = () => {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [accounts, setAccounts] = useState([]);
  const [transactions, setTransactions] = useState([]);
  const [investments, setInvestments] = useState([]);
  
  // Mock user state (replace with actual auth later)
  const [user] = useState({ name: 'John Doe', email: 'john@example.com' });
  const logout = () => {
    // Mock logout function - implement actual logout later
    alert('Logout clicked - implement actual logout functionality');
  };

  // Account form state
  const [newAccount, setNewAccount] = useState({
    name: '',
    type: 'checking',
    balance: ''
  });

  // Transaction form state
  const [newTransaction, setNewTransaction] = useState({
    accountId: '',
    type: 'expense',
    category: '',
    amount: '',
    description: ''
  });

  // Investment form state
  const [newInvestment, setNewInvestment] = useState({
    symbol: '',
    shares: '',
    price: '',
    type: 'stock'
  });

  // Sample data for demonstration
  React.useEffect(() => {
    setAccounts([
      { id: 1, name: 'Main Checking', type: 'checking', balance: 5000 },
      { id: 2, name: 'Savings', type: 'savings', balance: 15000 }
    ]);

    setTransactions([
      { id: 1, accountId: 1, type: 'expense', category: 'Food', amount: 25.50, description: 'Lunch', date: '2024-01-15' },
      { id: 2, accountId: 1, type: 'income', category: 'Salary', amount: 3000, description: 'Monthly salary', date: '2024-01-01' }
    ]);

    setInvestments([
      { id: 1, symbol: 'AAPL', shares: 10, price: 150, type: 'stock', value: 1500 }
    ]);
  }, []);

  // Remove console.log statements and implement proper functionality
  const handleCreateAccount = (e) => {
    e.preventDefault();
    if (newAccount.name && newAccount.balance) {
      const account = {
        id: Date.now(),
        name: newAccount.name,
        type: newAccount.type,
        balance: parseFloat(newAccount.balance)
      };
      setAccounts(prev => [...prev, account]);
      setNewAccount({ name: '', type: 'checking', balance: '' });
      setActiveTab('dashboard'); // Navigate back to dashboard
    }
  };

  const handleCreateTransaction = (e) => {
    e.preventDefault();
    if (newTransaction.accountId && newTransaction.amount && newTransaction.description) {
      const transaction = {
        id: Date.now(),
        accountId: parseInt(newTransaction.accountId),
        type: newTransaction.type,
        category: newTransaction.category,
        amount: parseFloat(newTransaction.amount),
        description: newTransaction.description,
        date: new Date().toISOString().split('T')[0]
      };
      setTransactions(prev => [...prev, transaction]);
      setNewTransaction({ accountId: '', type: 'expense', category: '', amount: '', description: '' });
      setActiveTab('dashboard'); // Navigate back to dashboard
    }
  };

  const handleCreateInvestment = (e) => {
    e.preventDefault();
    if (newInvestment.symbol && newInvestment.shares && newInvestment.price) {
      const investment = {
        id: Date.now(),
        symbol: newInvestment.symbol.toUpperCase(),
        shares: parseInt(newInvestment.shares),
        price: parseFloat(newInvestment.price),
        type: newInvestment.type,
        value: parseInt(newInvestment.shares) * parseFloat(newInvestment.price)
      };
      setInvestments(prev => [...prev, investment]);
      setNewInvestment({ symbol: '', shares: '', price: '', type: 'stock' });
      setActiveTab('dashboard'); // Navigate back to dashboard
    }
  };

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return (
          <div className="space-y-6">
            {/* User Welcome */}
            {user && (
              <div className="bg-blue-50 p-4 rounded-lg">
                <h2 className="text-xl font-semibold text-blue-800">Welcome back, {user.name || 'User'}!</h2>
                <button 
                  onClick={logout}
                  className="mt-2 text-sm text-blue-600 hover:text-blue-800"
                >
                  Logout
                </button>
              </div>
            )}

            {/* Overview Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="bg-white p-6 rounded-lg shadow">
                <h3 className="text-lg font-semibold mb-2">Total Balance</h3>
                <p className="text-3xl font-bold text-green-600">
                  ${accounts.reduce((sum, acc) => sum + acc.balance, 0).toLocaleString()}
                </p>
              </div>
              <div className="bg-white p-6 rounded-lg shadow">
                <h3 className="text-lg font-semibold mb-2">Accounts</h3>
                <p className="text-3xl font-bold text-blue-600">{accounts.length}</p>
              </div>
              <div className="bg-white p-6 rounded-lg shadow">
                <h3 className="text-lg font-semibold mb-2">Investments</h3>
                <p className="text-3xl font-bold text-purple-600">
                  ${investments.reduce((sum, inv) => sum + inv.value, 0).toLocaleString()}
                </p>
              </div>
            </div>

            {/* Accounts List */}
            <div className="bg-white p-6 rounded-lg shadow">
              <h3 className="text-lg font-semibold mb-4">Accounts</h3>
              {accounts.length === 0 ? (
                <p className="text-gray-500">No accounts yet. Create your first account!</p>
              ) : (
                <div className="space-y-2">
                  {accounts.map(account => (
                    <div key={account.id} className="flex justify-between items-center p-3 bg-gray-50 rounded">
                      <div>
                        <p className="font-medium">{account.name}</p>
                        <p className="text-sm text-gray-500 capitalize">{account.type}</p>
                      </div>
                      <p className="text-lg font-semibold">${account.balance.toLocaleString()}</p>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Recent Transactions */}
            <div className="bg-white p-6 rounded-lg shadow">
              <h3 className="text-lg font-semibold mb-4">Recent Transactions</h3>
              {transactions.length === 0 ? (
                <p className="text-gray-500">No transactions yet. Add your first transaction!</p>
              ) : (
                <div className="space-y-2">
                  {transactions.slice(-5).reverse().map(transaction => (
                    <div key={transaction.id} className="flex justify-between items-center p-3 bg-gray-50 rounded">
                      <div>
                        <p className="font-medium">{transaction.description}</p>
                        <p className="text-sm text-gray-500">
                          {transaction.category} • {transaction.date}
                        </p>
                      </div>
                      <p className={`text-lg font-semibold ${
                        transaction.type === 'income' ? 'text-green-600' : 'text-red-600'
                      }`}>
                        {transaction.type === 'income' ? '+' : '-'}${transaction.amount.toLocaleString()}
                      </p>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        );

      case 'accounts':
        return (
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Create New Account</h2>
            <form onSubmit={handleCreateAccount} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Account Name</label>
                <input
                  type="text"
                  value={newAccount.name}
                  onChange={(e) => setNewAccount(prev => ({ ...prev, name: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Account Type</label>
                <select
                  value={newAccount.type}
                  onChange={(e) => setNewAccount(prev => ({ ...prev, type: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                >
                  <option value="checking">Checking</option>
                  <option value="savings">Savings</option>
                  <option value="credit">Credit Card</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Initial Balance</label>
                <input
                  type="number"
                  step="0.01"
                  value={newAccount.balance}
                  onChange={(e) => setNewAccount(prev => ({ ...prev, balance: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                  required
                />
              </div>
              <button type="submit" className="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600">
                Create Account
              </button>
            </form>
          </div>
        );

      case 'transactions':
        return (
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Add Transaction</h2>
            <form onSubmit={handleCreateTransaction} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Account</label>
                <select
                  value={newTransaction.accountId}
                  onChange={(e) => setNewTransaction(prev => ({ ...prev, accountId: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                  required
                >
                  <option value="">Select Account</option>
                  {accounts.map(account => (
                    <option key={account.id} value={account.id}>{account.name}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Type</label>
                <select
                  value={newTransaction.type}
                  onChange={(e) => setNewTransaction(prev => ({ ...prev, type: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                >
                  <option value="expense">Expense</option>
                  <option value="income">Income</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Category</label>
                <input
                  type="text"
                  value={newTransaction.category}
                  onChange={(e) => setNewTransaction(prev => ({ ...prev, category: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                  placeholder="e.g., Food, Salary, Entertainment"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Amount</label>
                <input
                  type="number"
                  step="0.01"
                  value={newTransaction.amount}
                  onChange={(e) => setNewTransaction(prev => ({ ...prev, amount: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Description</label>
                <input
                  type="text"
                  value={newTransaction.description}
                  onChange={(e) => setNewTransaction(prev => ({ ...prev, description: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                  required
                />
              </div>
              <button type="submit" className="bg-green-500 text-white px-4 py-2 rounded-lg hover:bg-green-600">
                Add Transaction
              </button>
            </form>
          </div>
        );

      case 'investments':
        return (
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Add Investment</h2>
            <form onSubmit={handleCreateInvestment} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Symbol</label>
                <input
                  type="text"
                  value={newInvestment.symbol}
                  onChange={(e) => setNewInvestment(prev => ({ ...prev, symbol: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                  placeholder="e.g., AAPL, GOOGL"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Shares</label>
                <input
                  type="number"
                  value={newInvestment.shares}
                  onChange={(e) => setNewInvestment(prev => ({ ...prev, shares: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Price per Share</label>
                <input
                  type="number"
                  step="0.01"
                  value={newInvestment.price}
                  onChange={(e) => setNewInvestment(prev => ({ ...prev, price: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Type</label>
                <select
                  value={newInvestment.type}
                  onChange={(e) => setNewInvestment(prev => ({ ...prev, type: e.target.value }))}
                  className="w-full p-2 border rounded-lg"
                >
                  <option value="stock">Stock</option>
                  <option value="bond">Bond</option>
                  <option value="etf">ETF</option>
                  <option value="crypto">Cryptocurrency</option>
                </select>
              </div>
              <button type="submit" className="bg-purple-500 text-white px-4 py-2 rounded-lg hover:bg-purple-600">
                Add Investment
              </button>
            </form>
          </div>
        );

      default:
        return (
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold">Page not found</h2>
            <p className="text-gray-600 mt-2">The requested page could not be found.</p>
          </div>
        );
    }
  };

  return (
    <div className="min-h-screen bg-gray-100">
      {/* Navigation */}
      <nav className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex">
              <div className="flex space-x-8">
                <button
                  onClick={() => setActiveTab('dashboard')}
                  className={`inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium ${
                    activeTab === 'dashboard'
                      ? 'border-blue-500 text-gray-900'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  Dashboard
                </button>
                <button
                  onClick={() => setActiveTab('accounts')}
                  className={`inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium ${
                    activeTab === 'accounts'
                      ? 'border-blue-500 text-gray-900'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  Accounts
                </button>
                <button
                  onClick={() => setActiveTab('transactions')}
                  className={`inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium ${
                    activeTab === 'transactions'
                      ? 'border-blue-500 text-gray-900'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  Transactions
                </button>
                <button
                  onClick={() => setActiveTab('investments')}
                  className={`inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium ${
                    activeTab === 'investments'
                      ? 'border-blue-500 text-gray-900'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  Investments
                </button>
              </div>
            </div>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          {renderContent()}
        </div>
      </main>
    </div>
  );
};

export default FinanceApp;