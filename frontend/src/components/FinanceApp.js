import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { accountService } from '../services/accountService';
import { transactionService } from '../services/transactionService';
import { budgetService } from '../services/budgetService';
import { investmentService } from '../services/investmentService';
import { categoryService } from '../services/categoryService';
import { formatIDR } from '../utils/currency';

const FinanceApp = () => {
  const [activeTab, setActiveTab] = useState('dashboard');
  const { user, logout } = useAuth();
  const [accounts, setAccounts] = useState([]);
  const [transactions, setTransactions] = useState([]);
  const [investments, setInvestments] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

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

  // Category form state
  const [newCategory, setNewCategory] = useState({
    name: '',
    type: 'expense',
    color: '#3B82F6',
    icon: '💰',
    description: ''
  });

  const [editingCategory, setEditingCategory] = useState(null);

  // Transaction editing state
  const [editingTransaction, setEditingTransaction] = useState(null);
  const [showTransactionForm, setShowTransactionForm] = useState(false);


  // Account editing state
  const [editingAccount, setEditingAccount] = useState(null);

  // Investment editing state
  const [editingInvestment, setEditingInvestment] = useState(null);

  // Load initial data from API
  useEffect(() => {
    loadAllData();
  }, []);


  const loadAllData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Load data in parallel
      const [accountsRes, transactionsRes, investmentsRes, categoriesRes] = await Promise.all([
        accountService.getAll(),
        transactionService.getAll(),
        investmentService.getAll(),
        categoryService.getAll()
      ]);

      setAccounts(accountsRes.data.data);
      setTransactions(transactionsRes.data.data.data); // Paginated response
      setInvestments(investmentsRes.data.data);
      setCategories(categoriesRes.data.data);
      
    } catch (error) {
      console.error('Error loading data:', error);
      setError('Failed to load data. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateAccount = async (e) => {
    e.preventDefault();
    if (newAccount.name && newAccount.balance) {
      try {
        const response = await accountService.create({
          name: newAccount.name,
          type: newAccount.type,
          balance: parseFloat(newAccount.balance)
        });
        
        if (response.data.success) {
          setAccounts(prev => [...prev, response.data.data]);
          setNewAccount({ name: '', type: 'checking', balance: '' });
          setEditingAccount(null);
        }
      } catch (error) {
        console.error('Error creating account:', error);
        setError('Failed to create account. Please try again.');
      }
    }
  };

  const handleCreateTransaction = async (e) => {
    e.preventDefault();
    if (newTransaction.accountId && newTransaction.amount && newTransaction.description && newTransaction.category) {
      try {
        const response = await transactionService.create({
          account_id: parseInt(newTransaction.accountId),
          category_id: parseInt(newTransaction.category),
          type: newTransaction.type,
          amount: parseFloat(newTransaction.amount),
          description: newTransaction.description,
          transaction_date: new Date().toISOString().split('T')[0]
        });
        
        if (response.data.success) {
          setTransactions(prev => [response.data.data, ...prev]);
          // Update account balance in local state
          setAccounts(prev => prev.map(acc => 
            acc.id === response.data.data.account.id 
              ? { ...acc, balance: response.data.data.account.balance }
              : acc
          ));
          setNewTransaction({ accountId: '', type: 'expense', category: '', amount: '', description: '' });
          setShowTransactionForm(false);
        }
      } catch (error) {
        console.error('Error creating transaction:', error);
        setError('Failed to create transaction. Please try again.');
      }
    }
  };

  const handleCreateInvestment = async (e) => {
    e.preventDefault();
    if (newInvestment.symbol && newInvestment.shares && newInvestment.price) {
      try {
        const response = await investmentService.create({
          name: newInvestment.symbol.toUpperCase(),
          symbol: newInvestment.symbol.toUpperCase(),
          type: newInvestment.type,
          quantity: parseInt(newInvestment.shares),
          purchase_price: parseFloat(newInvestment.price),
          current_price: parseFloat(newInvestment.price),
          purchase_date: new Date().toISOString().split('T')[0]
        });
        
        if (response.data.success) {
          setInvestments(prev => [...prev, response.data.data]);
          setNewInvestment({ symbol: '', shares: '', price: '', type: 'stock' });
          setEditingInvestment(null);
        }
      } catch (error) {
        console.error('Error creating investment:', error);
        setError('Failed to create investment. Please try again.');
      }
    }
  };

  const handleCreateCategory = async (e) => {
    e.preventDefault();
    if (newCategory.name && newCategory.type) {
      try {
        const response = await categoryService.create({
          name: newCategory.name,
          type: newCategory.type,
          color: newCategory.color,
          icon: newCategory.icon,
          description: newCategory.description
        });
        
        if (response.data.success) {
          setCategories(prev => [...prev, response.data.data]);
          setNewCategory({ name: '', type: 'expense', color: '#3B82F6', icon: '💰', description: '' });
          setActiveTab('dashboard');
        }
      } catch (error) {
        console.error('Error creating category:', error);
        setError('Failed to create category. Please try again.');
      }
    }
  };

  const handleUpdateCategory = async (e) => {
    e.preventDefault();
    if (editingCategory && editingCategory.name && editingCategory.type) {
      try {
        const response = await categoryService.update(editingCategory.id, {
          name: editingCategory.name,
          type: editingCategory.type,
          color: editingCategory.color,
          icon: editingCategory.icon,
          description: editingCategory.description
        });
        
        if (response.data.success) {
          setCategories(prev => prev.map(cat => 
            cat.id === editingCategory.id ? response.data.data : cat
          ));
          setEditingCategory(null);
        }
      } catch (error) {
        console.error('Error updating category:', error);
        setError('Failed to update category. Please try again.');
      }
    }
  };

  const handleDeleteCategory = async (id) => {
    if (window.confirm('Are you sure you want to delete this category?')) {
      try {
        await categoryService.delete(id);
        setCategories(prev => prev.filter(cat => cat.id !== id));
      } catch (error) {
        console.error('Error deleting category:', error);
        setError('Failed to delete category. Please try again.');
      }
    }
  };

  const handleUpdateTransaction = async (e) => {
    e.preventDefault();
    if (editingTransaction && editingTransaction.account_id && editingTransaction.amount && editingTransaction.description && editingTransaction.category_id) {
      try {
        const response = await transactionService.update(editingTransaction.id, {
          account_id: parseInt(editingTransaction.account_id),
          category_id: parseInt(editingTransaction.category_id),
          type: editingTransaction.type,
          amount: parseFloat(editingTransaction.amount),
          description: editingTransaction.description,
          transaction_date: editingTransaction.transaction_date || new Date().toISOString().split('T')[0]
        });
        
        if (response.data.success) {
          setTransactions(prev => prev.map(trans => 
            trans.id === editingTransaction.id ? response.data.data : trans
          ));
          // Update account balances
          await loadAllData(); // Reload all data to get updated balances
          setEditingTransaction(null);
          setShowTransactionForm(false);
        }
      } catch (error) {
        console.error('Error updating transaction:', error);
        setError('Failed to update transaction. Please try again.');
      }
    }
  };

  const handleDeleteTransaction = async (id) => {
    if (window.confirm('Are you sure you want to delete this transaction?')) {
      try {
        await transactionService.delete(id);
        setTransactions(prev => prev.filter(trans => trans.id !== id));
        // Reload all data to get updated account balances
        await loadAllData();
      } catch (error) {
        console.error('Error deleting transaction:', error);
        setError('Failed to delete transaction. Please try again.');
      }
    }
  };

  const handleEditTransaction = (transaction) => {
    setEditingTransaction({
      id: transaction.id,
      account_id: transaction.account_id,
      category_id: transaction.category_id,
      type: transaction.type,
      amount: transaction.amount,
      description: transaction.description,
      transaction_date: transaction.transaction_date || new Date().toISOString().split('T')[0]
    });
    setShowTransactionForm(true);
  };

  const handleUpdateAccount = async (e) => {
    e.preventDefault();
    if (editingAccount && editingAccount.name && editingAccount.balance !== '') {
      try {
        const response = await accountService.update(editingAccount.id, {
          name: editingAccount.name,
          type: editingAccount.type,
          balance: parseFloat(editingAccount.balance)
        });
        
        if (response.data.success) {
          setAccounts(prev => prev.map(acc => 
            acc.id === editingAccount.id ? response.data.data : acc
          ));
          setEditingAccount(null);
          setNewAccount({ name: '', type: 'checking', balance: '' });
        }
      } catch (error) {
        console.error('Error updating account:', error);
        setError('Failed to update account. Please try again.');
      }
    }
  };

  const handleDeleteAccount = async (id) => {
    if (window.confirm('Are you sure you want to delete this account? All associated transactions will also be deleted.')) {
      try {
        await accountService.delete(id);
        setAccounts(prev => prev.filter(acc => acc.id !== id));
        // Reload all data to get updated transactions after account deletion
        await loadAllData();
      } catch (error) {
        console.error('Error deleting account:', error);
        setError('Failed to delete account. Please try again.');
      }
    }
  };

  const handleEditAccount = (account) => {
    setEditingAccount({
      id: account.id,
      name: account.name,
      type: account.type,
      balance: account.balance
    });
  };

  const handleUpdateInvestment = async (e) => {
    e.preventDefault();
    if (editingInvestment && editingInvestment.name && editingInvestment.quantity && editingInvestment.purchase_price) {
      try {
        const response = await investmentService.update(editingInvestment.id, {
          name: editingInvestment.name.toUpperCase(),
          symbol: editingInvestment.symbol?.toUpperCase() || editingInvestment.name.toUpperCase(),
          type: editingInvestment.type,
          quantity: parseInt(editingInvestment.quantity),
          purchase_price: parseFloat(editingInvestment.purchase_price),
          current_price: parseFloat(editingInvestment.current_price || editingInvestment.purchase_price),
          purchase_date: editingInvestment.purchase_date || new Date().toISOString().split('T')[0]
        });
        
        if (response.data.success) {
          setInvestments(prev => prev.map(inv => 
            inv.id === editingInvestment.id ? response.data.data : inv
          ));
          setEditingInvestment(null);
          setNewInvestment({ symbol: '', shares: '', price: '', type: 'stock' });
        }
      } catch (error) {
        console.error('Error updating investment:', error);
        setError('Failed to update investment. Please try again.');
      }
    }
  };

  const handleDeleteInvestment = async (id) => {
    if (window.confirm('Are you sure you want to delete this investment?')) {
      try {
        await investmentService.delete(id);
        setInvestments(prev => prev.filter(inv => inv.id !== id));
      } catch (error) {
        console.error('Error deleting investment:', error);
        setError('Failed to delete investment. Please try again.');
      }
    }
  };

  const handleEditInvestment = (investment) => {
    setEditingInvestment({
      id: investment.id,
      name: investment.name || investment.symbol,
      symbol: investment.symbol,
      type: investment.type,
      quantity: investment.quantity,
      purchase_price: investment.purchase_price,
      current_price: investment.current_price,
      purchase_date: investment.purchase_date
    });
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500 mx-auto"></div>
          <p className="mt-4 text-lg text-gray-600">Loading your financial data...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded max-w-md">
            <p className="font-bold">Error Loading Data</p>
            <p>{error}</p>
            <button
              onClick={loadAllData}
              className="mt-2 bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600"
            >
              Try Again
            </button>
          </div>
        </div>
      </div>
    );
  }

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return (
          <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-100 -m-6">
            {/* Header with User Info */}
            {user && (
              <div className="bg-white/80 backdrop-blur-sm border-b border-white/20 px-4 sm:px-6 py-4 sticky top-0 z-10">
                <div className="max-w-7xl mx-auto flex justify-between items-center">
                  <div>
                    <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                      Hi, {user.name || 'User'}! 👋
                    </h1>
                    <p className="text-sm text-gray-600">Kelola keuangan Anda dengan mudah</p>
                  </div>
                  <button 
                    onClick={logout}
                    className="text-sm text-gray-500 hover:text-red-500 transition-colors"
                  >
                    Keluar
                  </button>
                </div>
              </div>
            )}

            <div className="max-w-7xl mx-auto px-4 sm:px-6 py-6 space-y-6">
              {/* Quick Stats - Mobile App Style */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="bg-gradient-to-r from-emerald-500 to-teal-600 p-6 rounded-2xl shadow-lg shadow-emerald-500/25 text-white">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-emerald-100 text-sm font-medium">Total Saldo</p>
                      <p className="text-2xl font-bold mt-1">
                        {formatIDR(accounts.reduce((sum, acc) => sum + parseFloat(acc.balance || 0), 0))}
                      </p>
                    </div>
                    <div className="bg-white/20 p-3 rounded-xl">
                      <span className="text-2xl">💰</span>
                    </div>
                  </div>
                </div>
                
                <div className="bg-gradient-to-r from-blue-500 to-indigo-600 p-6 rounded-2xl shadow-lg shadow-blue-500/25 text-white">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-blue-100 text-sm font-medium">Rekening</p>
                      <p className="text-2xl font-bold mt-1">{accounts.length}</p>
                    </div>
                    <div className="bg-white/20 p-3 rounded-xl">
                      <span className="text-2xl">🏦</span>
                    </div>
                  </div>
                </div>
                
                <div className="bg-gradient-to-r from-purple-500 to-pink-600 p-6 rounded-2xl shadow-lg shadow-purple-500/25 text-white">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-purple-100 text-sm font-medium">Investasi</p>
                      <p className="text-2xl font-bold mt-1">
                        {formatIDR(investments.reduce((sum, inv) => sum + (parseFloat(inv.quantity || 0) * parseFloat(inv.current_price || inv.purchase_price || 0)), 0))}
                      </p>
                    </div>
                    <div className="bg-white/20 p-3 rounded-xl">
                      <span className="text-2xl">📈</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Quick Actions - Grid Layout */}
              <div className="bg-white/60 backdrop-blur-sm p-4 rounded-2xl shadow-lg border border-white/20">
                <div className="grid grid-cols-2 gap-3">
                  {/* Row 1: Income and Expense */}
                  <button
                    onClick={() => {
                      setEditingTransaction(null);
                      setNewTransaction({ accountId: '', type: 'income', category: '', amount: '', description: '' });
                      setShowTransactionForm(true);
                    }}
                    className="bg-gradient-to-r from-green-500 to-emerald-600 text-white p-4 rounded-xl shadow-lg shadow-green-500/25 hover:shadow-green-500/40 transition-all hover:scale-105"
                  >
                    <div className="text-2xl mb-1">💸</div>
                    <div className="text-sm font-medium">Pemasukan</div>
                  </button>
                  
                  <button
                    onClick={() => {
                      setEditingTransaction(null);
                      setNewTransaction({ accountId: '', type: 'expense', category: '', amount: '', description: '' });
                      setShowTransactionForm(true);
                    }}
                    className="bg-gradient-to-r from-red-500 to-rose-600 text-white p-4 rounded-xl shadow-lg shadow-red-500/25 hover:shadow-red-500/40 transition-all hover:scale-105"
                  >
                    <div className="text-2xl mb-1">💳</div>
                    <div className="text-sm font-medium">Pengeluaran</div>
                  </button>
                  
                  {/* Row 2: Logo and Menu */}
                  <div className="bg-gradient-to-r from-indigo-600 to-purple-700 p-4 rounded-xl shadow-lg shadow-indigo-500/25 flex items-center justify-center text-white">
                    <div className="text-center">
                      <div className="text-2xl mb-1">🏛️</div>
                      <div className="text-sm font-bold">BankQu</div>
                    </div>
                  </div>
                  
                  <button
                    onClick={() => setActiveTab('menu')}
                    className="bg-gradient-to-r from-gray-600 to-slate-700 text-white p-4 rounded-xl shadow-lg shadow-gray-500/25 hover:shadow-gray-500/40 transition-all hover:scale-105"
                  >
                    <div className="text-2xl mb-1">☰</div>
                    <div className="text-sm font-medium">Menu</div>
                  </button>
                </div>
              </div>

              {/* Accounts & Transactions Grid - 2 Columns */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Accounts Overview */}
                {accounts.length > 0 && (
                  <div className="bg-white/60 backdrop-blur-sm p-4 rounded-2xl shadow-lg border border-white/20">
                    <h3 className="text-lg font-bold text-gray-800 mb-3">Rekening Saya</h3>
                    <div className="space-y-2">
                      {accounts.map(account => (
                        <div key={account.id} className="bg-white/80 p-4 rounded-xl border border-gray-100 hover:shadow-md transition-all">
                          <div className="flex justify-between items-center">
                            <div>
                              <p className="font-semibold text-gray-800">{account.name}</p>
                              <p className="text-xs text-gray-500 capitalize">
                                {account.type === 'checking' ? 'Giro' : 
                                 account.type === 'savings' ? 'Tabungan' : 
                                 account.type === 'credit' ? 'Kartu Kredit' : account.type}
                              </p>
                            </div>
                            <p className="text-lg font-bold text-emerald-600">{formatIDR(account.balance || 0)}</p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Recent Transactions */}
                {transactions.length > 0 && (
                  <div className="bg-white/60 backdrop-blur-sm p-4 rounded-2xl shadow-lg border border-white/20">
                    <div className="flex justify-between items-center mb-4">
                      <h3 className="text-lg font-bold text-gray-800">Transaksi Terbaru</h3>
                      <button
                        onClick={() => setActiveTab('transactions')}
                        className="text-sm text-blue-600 hover:text-blue-800 font-medium"
                      >
                        Lihat Semua
                      </button>
                    </div>
                    <div className="space-y-3">
                      {transactions.slice(-5).reverse().map(transaction => (
                        <div key={transaction.id} className="bg-white/80 p-4 rounded-xl border border-gray-100 hover:shadow-md transition-all">
                          <div className="flex items-center justify-between">
                            <div className="flex items-center space-x-3">
                              <div className={`p-2 rounded-xl ${
                                transaction.type === 'income' 
                                  ? 'bg-green-100 text-green-700' 
                                  : 'bg-red-100 text-red-700'
                              }`}>
                                <span className="text-sm">{transaction.category?.icon || (transaction.type === 'income' ? '💸' : '💳')}</span>
                              </div>
                              <div>
                                <p className="font-semibold text-gray-800">{transaction.description}</p>
                                <p className="text-xs text-gray-500">
                                  {transaction.category?.name || 'Unknown'} • {new Date(transaction.transaction_date || transaction.created_at).toLocaleDateString('id-ID')}
                                </p>
                              </div>
                            </div>
                            <div className="text-right">
                              <p className={`font-bold ${
                                transaction.type === 'income' ? 'text-green-600' : 'text-red-600'
                              }`}>
                                {transaction.type === 'income' ? '+' : '-'}{formatIDR(transaction.amount || 0)}
                              </p>
                              <div className="flex space-x-1 mt-1">
                                <button
                                  onClick={() => handleEditTransaction(transaction)}
                                  className="text-xs text-blue-500 hover:text-blue-700 px-2 py-1 bg-blue-50 rounded-lg transition-all"
                                >
                                  Edit
                                </button>
                                <button
                                  onClick={() => handleDeleteTransaction(transaction.id)}
                                  className="text-xs text-red-500 hover:text-red-700 px-2 py-1 bg-red-50 rounded-lg transition-all"
                                >
                                  Hapus
                                </button>
                              </div>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {/* Transaction Form - Modern Modal Style */}
              {showTransactionForm && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                  <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full max-h-[90vh] overflow-y-auto">
                    <div className="p-6">
                      <div className="flex justify-between items-center mb-6">
                        <h4 className="text-xl font-bold text-gray-800">
                          {editingTransaction ? 'Edit Transaksi' : 'Transaksi Baru'}
                        </h4>
                        <button
                          onClick={() => {
                            setShowTransactionForm(false);
                            setEditingTransaction(null);
                          }}
                          className="text-gray-400 hover:text-gray-600 transition-colors"
                        >
                          <span className="text-2xl">&times;</span>
                        </button>
                      </div>
                      
                      <form onSubmit={editingTransaction ? handleUpdateTransaction : handleCreateTransaction} className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">Rekening</label>
                          <select
                            value={editingTransaction ? editingTransaction.account_id : newTransaction.accountId}
                            onChange={(e) => editingTransaction 
                              ? setEditingTransaction(prev => ({ ...prev, account_id: e.target.value }))
                              : setNewTransaction(prev => ({ ...prev, accountId: e.target.value }))
                            }
                            className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                            required
                          >
                            <option value="">Pilih Rekening</option>
                            {accounts.map(account => (
                              <option key={account.id} value={account.id}>{account.name}</option>
                            ))}
                          </select>
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">Tipe</label>
                          <div className="grid grid-cols-2 gap-2">
                            <button
                              type="button"
                              onClick={() => editingTransaction 
                                ? setEditingTransaction(prev => ({ ...prev, type: 'income' }))
                                : setNewTransaction(prev => ({ ...prev, type: 'income' }))
                              }
                              className={`p-3 rounded-xl border-2 transition-all ${
                                (editingTransaction ? editingTransaction.type : newTransaction.type) === 'income'
                                  ? 'border-green-500 bg-green-50 text-green-700'
                                  : 'border-gray-200 hover:border-green-300'
                              }`}
                            >
                              💸 Pemasukan
                            </button>
                            <button
                              type="button"
                              onClick={() => editingTransaction 
                                ? setEditingTransaction(prev => ({ ...prev, type: 'expense' }))
                                : setNewTransaction(prev => ({ ...prev, type: 'expense' }))
                              }
                              className={`p-3 rounded-xl border-2 transition-all ${
                                (editingTransaction ? editingTransaction.type : newTransaction.type) === 'expense'
                                  ? 'border-red-500 bg-red-50 text-red-700'
                                  : 'border-gray-200 hover:border-red-300'
                              }`}
                            >
                              💳 Pengeluaran
                            </button>
                          </div>
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">Kategori</label>
                          <select
                            value={editingTransaction ? editingTransaction.category_id : newTransaction.category}
                            onChange={(e) => editingTransaction 
                              ? setEditingTransaction(prev => ({ ...prev, category_id: e.target.value }))
                              : setNewTransaction(prev => ({ ...prev, category: e.target.value }))
                            }
                            className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                            required
                          >
                            <option value="">Pilih Kategori</option>
                            {categories
                              .filter(cat => cat.type === (editingTransaction ? editingTransaction.type : newTransaction.type))
                              .map(category => (
                                <option key={category.id} value={category.id}>
                                  {category.icon} {category.name}
                                </option>
                              ))
                            }
                          </select>
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">Jumlah (IDR)</label>
                          <input
                            type="number"
                            step="0.01"
                            value={editingTransaction ? editingTransaction.amount : newTransaction.amount}
                            onChange={(e) => editingTransaction 
                              ? setEditingTransaction(prev => ({ ...prev, amount: e.target.value }))
                              : setNewTransaction(prev => ({ ...prev, amount: e.target.value }))
                            }
                            className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                            placeholder="0"
                            required
                          />
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">Deskripsi</label>
                          <input
                            type="text"
                            value={editingTransaction ? editingTransaction.description : newTransaction.description}
                            onChange={(e) => editingTransaction 
                              ? setEditingTransaction(prev => ({ ...prev, description: e.target.value }))
                              : setNewTransaction(prev => ({ ...prev, description: e.target.value }))
                            }
                            className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                            placeholder="Contoh: Makan siang, Gaji, dll."
                            required
                          />
                        </div>
                        
                        {editingTransaction && (
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">Tanggal</label>
                            <input
                              type="date"
                              value={editingTransaction.transaction_date}
                              onChange={(e) => setEditingTransaction(prev => ({ ...prev, transaction_date: e.target.value }))}
                              className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                            />
                          </div>
                        )}
                        
                        <div className="flex space-x-3 pt-4">
                          <button 
                            type="submit" 
                            className="flex-1 bg-gradient-to-r from-blue-500 to-indigo-600 text-white py-3 rounded-xl font-medium hover:shadow-lg transition-all"
                          >
                            {editingTransaction ? 'Update' : 'Simpan'}
                          </button>
                          <button 
                            type="button"
                            onClick={() => {
                              setShowTransactionForm(false);
                              setEditingTransaction(null);
                            }}
                            className="px-6 bg-gray-100 text-gray-700 py-3 rounded-xl font-medium hover:bg-gray-200 transition-all"
                          >
                            Batal
                          </button>
                        </div>
                      </form>
                    </div>
                  </div>
                </div>
              )}

            </div>
          </div>
        );

      case 'accounts':
        return (
          <div className="space-y-6">
            {/* Account Form */}
            <div className="bg-white p-6 rounded-lg shadow">
              <h2 className="text-xl font-semibold mb-4">
                {editingAccount ? 'Edit Rekening' : 'Tambah Rekening Baru'}
              </h2>
              <form onSubmit={editingAccount ? handleUpdateAccount : handleCreateAccount} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Nama Rekening</label>
                  <input
                    type="text"
                    value={editingAccount ? editingAccount.name : newAccount.name}
                    onChange={(e) => editingAccount 
                      ? setEditingAccount(prev => ({ ...prev, name: e.target.value }))
                      : setNewAccount(prev => ({ ...prev, name: e.target.value }))
                    }
                    className="w-full p-2 border rounded-lg"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Tipe Rekening</label>
                  <select
                    value={editingAccount ? editingAccount.type : newAccount.type}
                    onChange={(e) => editingAccount 
                      ? setEditingAccount(prev => ({ ...prev, type: e.target.value }))
                      : setNewAccount(prev => ({ ...prev, type: e.target.value }))
                    }
                    className="w-full p-2 border rounded-lg"
                  >
                    <option value="checking">Giro</option>
                    <option value="savings">Tabungan</option>
                    <option value="credit">Kartu Kredit</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">
                    {editingAccount ? 'Saldo Saat Ini (IDR)' : 'Saldo Awal (IDR)'}
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    value={editingAccount ? editingAccount.balance : newAccount.balance}
                    onChange={(e) => editingAccount 
                      ? setEditingAccount(prev => ({ ...prev, balance: e.target.value }))
                      : setNewAccount(prev => ({ ...prev, balance: e.target.value }))
                    }
                    className="w-full p-2 border rounded-lg"
                    required
                  />
                </div>
                <div className="flex space-x-2">
                  <button type="submit" className={`px-4 py-2 rounded-lg text-white ${
                    editingAccount 
                      ? 'bg-blue-500 hover:bg-blue-600' 
                      : 'bg-green-500 hover:bg-green-600'
                  }`}>
                    {editingAccount ? 'Update Rekening' : 'Tambah Rekening'}
                  </button>
                  {editingAccount && (
                    <button 
                      type="button"
                      onClick={() => {
                        setEditingAccount(null);
                        setNewAccount({ name: '', type: 'checking', balance: '' });
                      }}
                      className="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600"
                    >
                      Batal
                    </button>
                  )}
                </div>
              </form>
            </div>

            {/* Accounts List - Grid Layout */}
            <div className="bg-white/60 backdrop-blur-sm p-6 rounded-2xl shadow-lg border border-white/20">
              <h3 className="text-lg font-bold text-gray-800 mb-4">Daftar Rekening</h3>
              {accounts.length === 0 ? (
                <p className="text-gray-500">Belum ada rekening. Tambah rekening pertama Anda!</p>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {accounts.map(account => (
                    <div key={account.id} className="bg-white/80 p-4 rounded-xl border border-gray-100 hover:shadow-md transition-all">
                      <div className="flex items-center justify-between mb-3">
                        <div className={`p-2 rounded-xl ${
                          account.type === 'savings' ? 'bg-green-100 text-green-700' :
                          account.type === 'checking' ? 'bg-blue-100 text-blue-700' :
                          'bg-purple-100 text-purple-700'
                        }`}>
                          <span className="text-xl">
                            {account.type === 'savings' ? '🏦' :
                             account.type === 'checking' ? '💳' : '💎'}
                          </span>
                        </div>
                        <div className="flex space-x-1">
                          <button
                            onClick={() => handleEditAccount(account)}
                            className="text-blue-500 hover:text-blue-700 px-2 py-1 bg-blue-50 rounded-lg text-xs transition-all"
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => handleDeleteAccount(account.id)}
                            className="text-red-500 hover:text-red-700 px-2 py-1 bg-red-50 rounded-lg text-xs transition-all"
                          >
                            Hapus
                          </button>
                        </div>
                      </div>
                      <div>
                        <h4 className="font-bold text-gray-800 text-lg mb-1">{account.name}</h4>
                        <p className="text-sm text-gray-500 capitalize mb-2">
                          {account.type === 'checking' ? 'Giro' : 
                           account.type === 'savings' ? 'Tabungan' : 
                           account.type === 'credit' ? 'Kartu Kredit' : account.type}
                        </p>
                        <p className="text-xl font-bold text-emerald-600">
                          {formatIDR(account.balance || 0)}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        );

      case 'transactions':
        return (
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Log Lengkap Transaksi</h2>
            
            {/* Full Transaction List */}
            {transactions.length === 0 ? (
              <p className="text-gray-500">Belum ada transaksi.</p>
            ) : (
              <div className="space-y-2">
                <p className="text-sm text-gray-600 mb-4">Total {transactions.length} transaksi</p>
                {transactions.map(transaction => (
                  <div key={transaction.id} className="flex justify-between items-center p-3 bg-gray-50 rounded">
                    <div className="flex-1">
                      <p className="font-medium">{transaction.description}</p>
                      <p className="text-sm text-gray-500">
                        {transaction.category?.name || 'Unknown'} • {transaction.account?.name || 'Unknown Account'} • {new Date(transaction.transaction_date || transaction.created_at).toLocaleDateString('id-ID')}
                      </p>
                    </div>
                    <div className="flex items-center space-x-3">
                      <p className={`text-lg font-semibold ${
                        transaction.type === 'income' ? 'text-green-600' : 'text-red-600'
                      }`}>
                        {transaction.type === 'income' ? '+' : '-'}{formatIDR(transaction.amount || 0)}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        );

      case 'investments':
        return (
          <div className="space-y-6">
            {/* Investment Form */}
            <div className="bg-white/60 backdrop-blur-sm p-6 rounded-2xl shadow-lg border border-white/20">
              <h2 className="text-xl font-bold text-gray-800 mb-4">
                {editingInvestment ? 'Edit Investasi' : 'Tambah Investasi Baru'}
              </h2>
              <form onSubmit={editingInvestment ? handleUpdateInvestment : handleCreateInvestment} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Nama/Symbol</label>
                  <input
                    type="text"
                    value={editingInvestment ? editingInvestment.name : newInvestment.symbol}
                    onChange={(e) => editingInvestment 
                      ? setEditingInvestment(prev => ({ ...prev, name: e.target.value, symbol: e.target.value }))
                      : setNewInvestment(prev => ({ ...prev, symbol: e.target.value }))
                    }
                    className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
                    placeholder="e.g., AAPL, GOOGL, BTC"
                    required
                  />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Jumlah</label>
                    <input
                      type="number"
                      value={editingInvestment ? editingInvestment.quantity : newInvestment.shares}
                      onChange={(e) => editingInvestment 
                        ? setEditingInvestment(prev => ({ ...prev, quantity: e.target.value }))
                        : setNewInvestment(prev => ({ ...prev, shares: e.target.value }))
                      }
                      className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Harga Beli (IDR)</label>
                    <input
                      type="number"
                      step="0.01"
                      value={editingInvestment ? editingInvestment.purchase_price : newInvestment.price}
                      onChange={(e) => editingInvestment 
                        ? setEditingInvestment(prev => ({ ...prev, purchase_price: e.target.value }))
                        : setNewInvestment(prev => ({ ...prev, price: e.target.value }))
                      }
                      className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
                      required
                    />
                  </div>
                </div>
                {editingInvestment && (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Harga Saat Ini (IDR)</label>
                      <input
                        type="number"
                        step="0.01"
                        value={editingInvestment.current_price}
                        onChange={(e) => setEditingInvestment(prev => ({ ...prev, current_price: e.target.value }))}
                        className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Tanggal Beli</label>
                      <input
                        type="date"
                        value={editingInvestment.purchase_date}
                        onChange={(e) => setEditingInvestment(prev => ({ ...prev, purchase_date: e.target.value }))}
                        className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
                      />
                    </div>
                  </div>
                )}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Tipe</label>
                  <select
                    value={editingInvestment ? editingInvestment.type : newInvestment.type}
                    onChange={(e) => editingInvestment 
                      ? setEditingInvestment(prev => ({ ...prev, type: e.target.value }))
                      : setNewInvestment(prev => ({ ...prev, type: e.target.value }))
                    }
                    className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
                  >
                    <option value="stock">Saham</option>
                    <option value="bond">Obligasi</option>
                    <option value="etf">ETF</option>
                    <option value="crypto">Cryptocurrency</option>
                  </select>
                </div>
                <div className="flex space-x-3">
                  <button 
                    type="submit" 
                    className={`flex-1 text-white py-3 rounded-xl font-medium transition-all ${
                      editingInvestment 
                        ? 'bg-gradient-to-r from-blue-500 to-indigo-600 hover:shadow-lg' 
                        : 'bg-gradient-to-r from-purple-500 to-indigo-600 hover:shadow-lg'
                    }`}
                  >
                    {editingInvestment ? 'Update Investasi' : 'Tambah Investasi'}
                  </button>
                  {editingInvestment && (
                    <button 
                      type="button"
                      onClick={() => {
                        setEditingInvestment(null);
                        setNewInvestment({ symbol: '', shares: '', price: '', type: 'stock' });
                      }}
                      className="px-6 bg-gray-100 text-gray-700 py-3 rounded-xl font-medium hover:bg-gray-200 transition-all"
                    >
                      Batal
                    </button>
                  )}
                </div>
              </form>
            </div>

            {/* Investments List - Grid Layout */}
            <div className="bg-white/60 backdrop-blur-sm p-6 rounded-2xl shadow-lg border border-white/20">
              <h3 className="text-lg font-bold text-gray-800 mb-4">Portfolio Investasi</h3>
              {investments.length === 0 ? (
                <p className="text-gray-500">Belum ada investasi. Tambah investasi pertama Anda!</p>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {investments.map(investment => {
                    const currentValue = (parseFloat(investment.quantity || 0) * parseFloat(investment.current_price || investment.purchase_price || 0));
                    const purchaseValue = (parseFloat(investment.quantity || 0) * parseFloat(investment.purchase_price || 0));
                    const profit = currentValue - purchaseValue;
                    const profitPercent = purchaseValue > 0 ? (profit / purchaseValue) * 100 : 0;
                    
                    return (
                      <div key={investment.id} className="bg-white/80 p-4 rounded-xl border border-gray-100 hover:shadow-md transition-all">
                        <div className="flex items-center justify-between mb-3">
                          <div className={`p-2 rounded-xl ${
                            investment.type === 'stock' ? 'bg-blue-100 text-blue-700' :
                            investment.type === 'crypto' ? 'bg-orange-100 text-orange-700' :
                            investment.type === 'etf' ? 'bg-green-100 text-green-700' :
                            'bg-purple-100 text-purple-700'
                          }`}>
                            <span className="text-xl">
                              {investment.type === 'stock' ? '📈' :
                               investment.type === 'crypto' ? '₿' :
                               investment.type === 'etf' ? '📊' : '🏛️'}
                            </span>
                          </div>
                          <div className="flex space-x-1">
                            <button
                              onClick={() => handleEditInvestment(investment)}
                              className="text-blue-500 hover:text-blue-700 px-2 py-1 bg-blue-50 rounded-lg text-xs transition-all"
                            >
                              Edit
                            </button>
                            <button
                              onClick={() => handleDeleteInvestment(investment.id)}
                              className="text-red-500 hover:text-red-700 px-2 py-1 bg-red-50 rounded-lg text-xs transition-all"
                            >
                              Hapus
                            </button>
                          </div>
                        </div>
                        <div>
                          <h4 className="font-bold text-gray-800 text-lg mb-1">
                            {investment.name || investment.symbol}
                          </h4>
                          <p className="text-sm text-gray-500 capitalize mb-2">
                            {investment.type === 'stock' ? 'Saham' :
                             investment.type === 'crypto' ? 'Cryptocurrency' :
                             investment.type === 'etf' ? 'ETF' :
                             investment.type === 'bond' ? 'Obligasi' : investment.type}
                          </p>
                          <div className="space-y-1">
                            <p className="text-sm text-gray-600">
                              {investment.quantity} × {formatIDR(investment.current_price || investment.purchase_price)}
                            </p>
                            <p className="text-xl font-bold text-purple-600">
                              {formatIDR(currentValue)}
                            </p>
                            {profit !== 0 && (
                              <p className={`text-sm font-medium ${profit >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                                {profit >= 0 ? '+' : ''}{formatIDR(profit)} ({profitPercent >= 0 ? '+' : ''}{profitPercent.toFixed(2)}%)
                              </p>
                            )}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        );

      case 'categories':
        return (
          <div className="space-y-6">
            {/* Category Form */}
            <div className="bg-white p-6 rounded-lg shadow">
              <h2 className="text-xl font-semibold mb-4">
                {editingCategory ? 'Edit Kategori' : 'Kelola Kategori'}
              </h2>
              <form onSubmit={editingCategory ? handleUpdateCategory : handleCreateCategory} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Category Name</label>
                  <input
                    type="text"
                    value={editingCategory ? editingCategory.name : newCategory.name}
                    onChange={(e) => editingCategory 
                      ? setEditingCategory(prev => ({ ...prev, name: e.target.value }))
                      : setNewCategory(prev => ({ ...prev, name: e.target.value }))
                    }
                    className="w-full p-2 border rounded-lg"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Type</label>
                  <select
                    value={editingCategory ? editingCategory.type : newCategory.type}
                    onChange={(e) => editingCategory 
                      ? setEditingCategory(prev => ({ ...prev, type: e.target.value }))
                      : setNewCategory(prev => ({ ...prev, type: e.target.value }))
                    }
                    className="w-full p-2 border rounded-lg"
                  >
                    <option value="expense">Expense</option>
                    <option value="income">Income</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Icon</label>
                  <input
                    type="text"
                    value={editingCategory ? editingCategory.icon : newCategory.icon}
                    onChange={(e) => editingCategory 
                      ? setEditingCategory(prev => ({ ...prev, icon: e.target.value }))
                      : setNewCategory(prev => ({ ...prev, icon: e.target.value }))
                    }
                    className="w-full p-2 border rounded-lg"
                    placeholder="e.g., 💰, 🍔, 🚗"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Color</label>
                  <input
                    type="color"
                    value={editingCategory ? editingCategory.color : newCategory.color}
                    onChange={(e) => editingCategory 
                      ? setEditingCategory(prev => ({ ...prev, color: e.target.value }))
                      : setNewCategory(prev => ({ ...prev, color: e.target.value }))
                    }
                    className="w-full p-2 border rounded-lg h-10"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Description</label>
                  <textarea
                    value={editingCategory ? editingCategory.description : newCategory.description}
                    onChange={(e) => editingCategory 
                      ? setEditingCategory(prev => ({ ...prev, description: e.target.value }))
                      : setNewCategory(prev => ({ ...prev, description: e.target.value }))
                    }
                    className="w-full p-2 border rounded-lg"
                    rows="3"
                    placeholder="Category description (optional)"
                  />
                </div>
                <div className="flex space-x-2">
                  <button 
                    type="submit" 
                    className={`px-4 py-2 rounded-lg text-white ${
                      editingCategory 
                        ? 'bg-blue-500 hover:bg-blue-600' 
                        : 'bg-green-500 hover:bg-green-600'
                    }`}
                  >
                    {editingCategory ? 'Update Category' : 'Create Category'}
                  </button>
                  {editingCategory && (
                    <button 
                      type="button"
                      onClick={() => {
                        setEditingCategory(null);
                        setNewCategory({ name: '', type: 'expense', color: '#3B82F6', icon: '💰', description: '' });
                      }}
                      className="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600"
                    >
                      Cancel
                    </button>
                  )}
                </div>
              </form>
            </div>

            {/* Categories List */}
            <div className="bg-white p-6 rounded-lg shadow">
              <h3 className="text-lg font-semibold mb-4">Categories</h3>
              {categories.length === 0 ? (
                <p className="text-gray-500">No categories yet. Create your first category!</p>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {categories.map(category => (
                    <div key={category.id} className="border rounded-lg p-4" style={{ borderColor: category.color }}>
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center space-x-2">
                          <span className="text-2xl">{category.icon}</span>
                          <div>
                            <h4 className="font-medium">{category.name}</h4>
                            <p className="text-sm text-gray-500 capitalize">{category.type}</p>
                          </div>
                        </div>
                        <div 
                          className="w-6 h-6 rounded-full border-2 border-gray-300" 
                          style={{ backgroundColor: category.color }}
                        />
                      </div>
                      {category.description && (
                        <p className="text-sm text-gray-600 mb-3">{category.description}</p>
                      )}
                      <div className="flex space-x-2">
                        <button
                          onClick={() => setEditingCategory(category)}
                          className="text-blue-500 hover:text-blue-700 text-sm"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => handleDeleteCategory(category.id)}
                          className="text-red-500 hover:text-red-700 text-sm"
                        >
                          Delete
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        );

      case 'menu':
        return (
          <div className="space-y-6">
            <div className="bg-white/60 backdrop-blur-sm p-6 rounded-2xl shadow-lg border border-white/20">
              <h2 className="text-xl font-bold text-gray-800 mb-4">Menu Navigasi</h2>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                <button
                  onClick={() => setActiveTab('accounts')}
                  className="bg-gradient-to-r from-blue-500 to-indigo-600 text-white p-4 rounded-xl shadow-lg shadow-blue-500/25 hover:shadow-blue-500/40 transition-all hover:scale-105"
                >
                  <div className="text-2xl mb-1">🏦</div>
                  <div className="text-sm font-medium">Rekening</div>
                </button>
                
                <button
                  onClick={() => setActiveTab('categories')}
                  className="bg-gradient-to-r from-purple-500 to-indigo-600 text-white p-4 rounded-xl shadow-lg shadow-purple-500/25 hover:shadow-purple-500/40 transition-all hover:scale-105"
                >
                  <div className="text-2xl mb-1">🏷️</div>
                  <div className="text-sm font-medium">Kategori</div>
                </button>
                
                <button
                  onClick={() => setActiveTab('investments')}
                  className="bg-gradient-to-r from-green-500 to-emerald-600 text-white p-4 rounded-xl shadow-lg shadow-green-500/25 hover:shadow-green-500/40 transition-all hover:scale-105"
                >
                  <div className="text-2xl mb-1">📈</div>
                  <div className="text-sm font-medium">Investasi</div>
                </button>
                
                <button
                  onClick={() => setActiveTab('transactions')}
                  className="bg-gradient-to-r from-indigo-500 to-purple-600 text-white p-4 rounded-xl shadow-lg shadow-indigo-500/25 hover:shadow-indigo-500/40 transition-all hover:scale-105"
                >
                  <div className="text-2xl mb-1">📊</div>
                  <div className="text-sm font-medium">Log Transaksi</div>
                </button>
              </div>
            </div>
            
            <div className="bg-white/60 backdrop-blur-sm p-6 rounded-2xl shadow-lg border border-white/20">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-lg font-bold text-gray-800">Kembali ke Dashboard</h3>
                  <p className="text-sm text-gray-600">Lihat ringkasan keuangan Anda</p>
                </div>
                <button
                  onClick={() => setActiveTab('dashboard')}
                  className="bg-gradient-to-r from-emerald-500 to-teal-600 text-white px-6 py-3 rounded-xl shadow-lg shadow-emerald-500/25 hover:shadow-emerald-500/40 transition-all hover:scale-105"
                >
                  <div className="flex items-center space-x-2">
                    <span className="text-lg">🏠</span>
                    <span className="font-medium">Dashboard</span>
                  </div>
                </button>
              </div>
            </div>
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
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-100">
      {/* Modern Navigation - Mobile App Style */}
      {activeTab !== 'dashboard' && (
        <nav className="bg-white/80 backdrop-blur-sm border-b border-white/20 sticky top-0 z-40">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between h-16">
              <div className="flex items-center space-x-6">
                <button
                  onClick={() => setActiveTab('dashboard')}
                  className="text-blue-600 hover:text-blue-800 font-medium flex items-center space-x-1"
                >
                  <span>←</span>
                  <span>Dashboard</span>
                </button>
                <div className="h-6 w-px bg-gray-300"></div>
                <div className="flex space-x-6">
                  <button
                    onClick={() => setActiveTab('accounts')}
                    className={`inline-flex items-center space-x-2 px-3 py-1 rounded-lg text-sm font-medium transition-all ${
                      activeTab === 'accounts'
                        ? 'bg-blue-100 text-blue-700'
                        : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                    }`}
                  >
                    <span>🏦</span>
                    <span>Rekening</span>
                  </button>
                  <button
                    onClick={() => setActiveTab('categories')}
                    className={`inline-flex items-center space-x-2 px-3 py-1 rounded-lg text-sm font-medium transition-all ${
                      activeTab === 'categories'
                        ? 'bg-blue-100 text-blue-700'
                        : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                    }`}
                  >
                    <span>🏷️</span>
                    <span>Kategori</span>
                  </button>
                  <button
                    onClick={() => setActiveTab('investments')}
                    className={`inline-flex items-center space-x-2 px-3 py-1 rounded-lg text-sm font-medium transition-all ${
                      activeTab === 'investments'
                        ? 'bg-blue-100 text-blue-700'
                        : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                    }`}
                  >
                    <span>📈</span>
                    <span>Investasi</span>
                  </button>
                  <button
                    onClick={() => setActiveTab('transactions')}
                    className={`inline-flex items-center space-x-2 px-3 py-1 rounded-lg text-sm font-medium transition-all ${
                      activeTab === 'transactions'
                        ? 'bg-blue-100 text-blue-700'
                        : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                    }`}
                  >
                    <span>📋</span>
                    <span>Full Log</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </nav>
      )}

      {/* Main Content */}
      <main className={`${activeTab === 'dashboard' ? '' : 'max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8'}`}>
        <div className={`${activeTab === 'dashboard' ? '' : 'py-6'}`}>
          {renderContent()}
        </div>
      </main>
    </div>
  );
};

export default FinanceApp;