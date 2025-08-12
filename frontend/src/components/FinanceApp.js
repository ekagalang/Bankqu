import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { accountService } from '../services/accountService';
import { transactionService } from '../services/transactionService';
import { investmentService } from '../services/investmentService';
import { budgetService } from '../services/budgetService';
import { PlusCircle, Wallet, TrendingUp, TrendingDown, PieChart, BarChart3, CreditCard, Building2, DollarSign, Calendar, Filter, Download, Eye, EyeOff } from 'lucide-react';

const FinanceApp = () => {
  const { user, logout } = useAuth();
  const [activeTab, setActiveTab] = useState('dashboard');
  const [showBalances, setShowBalances] = useState(true);
  const [transactions, setTransactions] = useState([
    { id: 1, type: 'income', category: 'Gaji', amount: 8000000, date: '2025-08-01', description: 'Gaji Bulanan', account: 'BCA' },
    { id: 2, type: 'expense', category: 'Makanan', amount: 150000, date: '2025-08-02', description: 'Makan siang', account: 'BCA' },
    { id: 3, type: 'expense', category: 'Transport', amount: 50000, date: '2025-08-03', description: 'Bensin motor', account: 'Cash' },
  ]);

  const [accounts, setAccounts] = useState([
    { id: 1, name: 'BCA', type: 'bank', balance: 15000000 },
    { id: 2, name: 'Mandiri', type: 'bank', balance: 5000000 },
    { id: 3, name: 'Cash', type: 'cash', balance: 500000 },
    { id: 4, name: 'OVO', type: 'ewallet', balance: 200000 },
  ]);

  const [investments, setInvestments] = useState([
    { id: 1, name: 'BBRI', type: 'saham', shares: 100, buyPrice: 4500, currentPrice: 4800, totalValue: 480000 },
    { id: 2, name: 'BBCA', type: 'saham', shares: 50, buyPrice: 8000, currentPrice: 8200, totalValue: 410000 },
    { id: 3, name: 'Reksadana Saham', type: 'reksadana', units: 1000, buyPrice: 1000, currentPrice: 1050, totalValue: 1050000 },
  ]);

  const [budgets, setBudgets] = useState([
    { id: 1, category: 'Makanan', budgeted: 2000000, spent: 850000, period: 'monthly' },
    { id: 2, category: 'Transport', budgeted: 800000, spent: 320000, period: 'monthly' },
    { id: 3, category: 'Hiburan', budgeted: 1000000, spent: 450000, period: 'monthly' },
  ]);

  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState('');
  const [formData, setFormData] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadAllData();
  }, []);

  const loadAllData = async () => {
    try {
      setLoading(true);
      const [accountsRes, transactionsRes, investmentsRes, budgetsRes] = await Promise.all([
        accountService.getAll(),
        transactionService.getAll(),
        investmentService.getAll(),
        budgetService.getAll()
      ]);

      setAccounts(accountsRes.data.data);
      setTransactions(transactionsRes.data.data.data || transactionsRes.data.data);
      setInvestments(investmentsRes.data.data.investments || investmentsRes.data.data);
      setBudgets(budgetsRes.data.data);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  // Functions untuk handle CRUD operations
  const handleCreateAccount = async (accountData) => {
    try {
      const response = await accountService.create(accountData);
      setAccounts([...accounts, response.data.data]);
      return { success: true };
    } catch (error) {
      console.error('Error creating account:', error);
      return { success: false, message: error.response?.data?.message };
    }
  };

  const handleCreateTransaction = async (transactionData) => {
    try {
      const response = await transactionService.create(transactionData);
      setTransactions([response.data.data, ...transactions]);
      // Reload accounts untuk update balance
      const accountsRes = await accountService.getAll();
      setAccounts(accountsRes.data.data);
      return { success: true };
    } catch (error) {
      console.error('Error creating transaction:', error);
      return { success: false, message: error.response?.data?.message };
    }
  };

  const handleCreateInvestment = async (investmentData) => {
    try {
      const response = await investmentService.create(investmentData);
      setInvestments([...investments, response.data.data]);
      return { success: true };
    } catch (error) {
      console.error('Error creating investment:', error);
      return { success: false, message: error.response?.data?.message };
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  // Perhitungan statistik
  const totalBalance = accounts.reduce((sum, acc) => sum + acc.balance, 0);
  const totalInvestments = investments.reduce((sum, inv) => sum + inv.totalValue, 0);
  const monthlyIncome = transactions.filter(t => t.type === 'income' && new Date(t.date).getMonth() === new Date().getMonth()).reduce((sum, t) => sum + t.amount, 0);
  const monthlyExpense = transactions.filter(t => t.type === 'expense' && new Date(t.date).getMonth() === new Date().getMonth()).reduce((sum, t) => sum + t.amount, 0);
  const netWorth = totalBalance + totalInvestments;

  const formatCurrency = (amount) => {
    if (!showBalances) return 'Rp ****';
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR' }).format(amount);
  };

  const getAccountIcon = (type) => {
    switch(type) {
      case 'bank': return <Building2 className="w-5 h-5" />;
      case 'cash': return <Wallet className="w-5 h-5" />;
      case 'ewallet': return <CreditCard className="w-5 h-5" />;
      default: return <Wallet className="w-5 h-5" />;
    }
  };

  const openModal = (type, data = {}) => {
    setModalType(type);
    setFormData(data);
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setFormData({});
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const newId = Date.now();
    
    switch(modalType) {
      case 'transaction':
        setTransactions([...transactions, { ...formData, id: newId, date: new Date().toISOString().split('T')[0] }]);
        break;
      case 'account':
        setAccounts([...accounts, { ...formData, id: newId }]);
        break;
      case 'investment':
        const totalValue = formData.shares * formData.currentPrice;
        setInvestments([...investments, { ...formData, id: newId, totalValue }]);
        break;
    }
    closeModal();
  };

  const DashboardView = () => (
    <div className="space-y-6">
      {/* Header Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-gradient-to-r from-blue-500 to-blue-600 p-6 rounded-xl text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-blue-100 text-sm">Total Saldo</p>
              <p className="text-2xl font-bold">{formatCurrency(totalBalance)}</p>
            </div>
            <Wallet className="w-8 h-8 text-blue-100" />
          </div>
        </div>
        
        <div className="bg-gradient-to-r from-green-500 to-green-600 p-6 rounded-xl text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-green-100 text-sm">Pemasukan Bulan Ini</p>
              <p className="text-2xl font-bold">{formatCurrency(monthlyIncome)}</p>
            </div>
            <TrendingUp className="w-8 h-8 text-green-100" />
          </div>
        </div>
        
        <div className="bg-gradient-to-r from-red-500 to-red-600 p-6 rounded-xl text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-red-100 text-sm">Pengeluaran Bulan Ini</p>
              <p className="text-2xl font-bold">{formatCurrency(monthlyExpense)}</p>
            </div>
            <TrendingDown className="w-8 h-8 text-red-100" />
          </div>
        </div>
        
        <div className="bg-gradient-to-r from-purple-500 to-purple-600 p-6 rounded-xl text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-purple-100 text-sm">Investasi</p>
              <p className="text-2xl font-bold">{formatCurrency(totalInvestments)}</p>
            </div>
            <TrendingUp className="w-8 h-8 text-purple-100" />
          </div>
        </div>
      </div>

      {/* Recent Transactions & Accounts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-800">Transaksi Terbaru</h3>
            <button 
              onClick={() => openModal('transaction')}
              className="text-blue-600 hover:text-blue-700 flex items-center gap-2"
            >
              <PlusCircle className="w-4 h-4" />
              Tambah
            </button>
          </div>
          <div className="space-y-3">
            {transactions.slice(0, 5).map(transaction => (
              <div key={transaction.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div>
                  <p className="font-medium text-gray-800">{transaction.description}</p>
                  <p className="text-sm text-gray-500">{transaction.category} • {transaction.date}</p>
                </div>
                <div className={`font-semibold ${transaction.type === 'income' ? 'text-green-600' : 'text-red-600'}`}>
                  {transaction.type === 'income' ? '+' : '-'}{formatCurrency(transaction.amount)}
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-800">Rekening & Saldo</h3>
            <button 
              onClick={() => openModal('account')}
              className="text-blue-600 hover:text-blue-700 flex items-center gap-2"
            >
              <PlusCircle className="w-4 h-4" />
              Tambah
            </button>
          </div>
          <div className="space-y-3">
            {accounts.map(account => (
              <div key={account.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex items-center gap-3">
                  {getAccountIcon(account.type)}
                  <div>
                    <p className="font-medium text-gray-800">{account.name}</p>
                    <p className="text-sm text-gray-500 capitalize">{account.type}</p>
                  </div>
                </div>
                <div className="font-semibold text-gray-800">
                  {formatCurrency(account.balance)}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Budget Overview */}
      <div className="bg-white p-6 rounded-xl shadow-sm border">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Budget Bulanan</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {budgets.map(budget => {
            const percentage = (budget.spent / budget.budgeted) * 100;
            const isOverBudget = percentage > 100;
            
            return (
              <div key={budget.id} className="p-4 bg-gray-50 rounded-lg">
                <div className="flex justify-between items-center mb-2">
                  <span className="font-medium text-gray-800">{budget.category}</span>
                  <span className={`text-sm ${isOverBudget ? 'text-red-600' : 'text-gray-600'}`}>
                    {percentage.toFixed(0)}%
                  </span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2 mb-2">
                  <div 
                    className={`h-2 rounded-full ${isOverBudget ? 'bg-red-500' : 'bg-blue-500'}`}
                    style={{ width: `${Math.min(percentage, 100)}%` }}
                  ></div>
                </div>
                <div className="flex justify-between text-sm text-gray-600">
                  <span>{formatCurrency(budget.spent)}</span>
                  <span>{formatCurrency(budget.budgeted)}</span>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );

  const InvestmentView = () => (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-gray-800">Investasi</h2>
        <button 
          onClick={() => openModal('investment')}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
        >
          <PlusCircle className="w-4 h-4" />
          Tambah Investasi
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-2">Total Investasi</h3>
          <p className="text-3xl font-bold text-blue-600">{formatCurrency(totalInvestments)}</p>
        </div>
        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-2">Total Gain/Loss</h3>
          <p className="text-3xl font-bold text-green-600">+{formatCurrency(125000)}</p>
        </div>
        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-2">Return</h3>
          <p className="text-3xl font-bold text-green-600">+6.8%</p>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm border">
        <div className="p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Portfolio Investasi</h3>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Nama</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Tipe</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Jumlah</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Harga Beli</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Harga Sekarang</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Total Nilai</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Gain/Loss</th>
                </tr>
              </thead>
              <tbody>
                {investments.map(investment => {
                  const gainLoss = (investment.currentPrice - investment.buyPrice) * investment.shares;
                  const gainLossPercentage = ((investment.currentPrice - investment.buyPrice) / investment.buyPrice) * 100;
                  
                  return (
                    <tr key={investment.id} className="border-b border-gray-100">
                      <td className="py-4 px-4 font-medium">{investment.name}</td>
                      <td className="py-4 px-4 capitalize">{investment.type}</td>
                      <td className="py-4 px-4">{investment.shares}</td>
                      <td className="py-4 px-4">{formatCurrency(investment.buyPrice)}</td>
                      <td className="py-4 px-4">{formatCurrency(investment.currentPrice)}</td>
                      <td className="py-4 px-4 font-semibold">{formatCurrency(investment.totalValue)}</td>
                      <td className={`py-4 px-4 font-semibold ${gainLoss >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {gainLoss >= 0 ? '+' : ''}{formatCurrency(gainLoss)}
                        <div className="text-xs">
                          ({gainLoss >= 0 ? '+' : ''}{gainLossPercentage.toFixed(2)}%)
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );

  const TransactionView = () => (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-gray-800">Transaksi</h2>
        <div className="flex gap-2">
          <button className="bg-gray-100 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-200 flex items-center gap-2">
            <Filter className="w-4 h-4" />
            Filter
          </button>
          <button className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center gap-2">
            <Download className="w-4 h-4" />
            Export
          </button>
          <button 
            onClick={() => openModal('transaction')}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
          >
            <PlusCircle className="w-4 h-4" />
            Tambah Transaksi
          </button>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm border">
        <div className="p-6">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Tanggal</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Deskripsi</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Kategori</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Akun</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Jumlah</th>
                  <th className="text-left py-3 px-4 font-semibold text-gray-700">Tipe</th>
                </tr>
              </thead>
              <tbody>
                {transactions.map(transaction => (
                  <tr key={transaction.id} className="border-b border-gray-100 hover:bg-gray-50">
                    <td className="py-4 px-4">{transaction.date}</td>
                    <td className="py-4 px-4 font-medium">{transaction.description}</td>
                    <td className="py-4 px-4">{transaction.category}</td>
                    <td className="py-4 px-4">{transaction.account}</td>
                    <td className={`py-4 px-4 font-semibold ${transaction.type === 'income' ? 'text-green-600' : 'text-red-600'}`}>
                      {transaction.type === 'income' ? '+' : '-'}{formatCurrency(transaction.amount)}
                    </td>
                    <td className="py-4 px-4">
                      <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                        transaction.type === 'income' 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {transaction.type === 'income' ? 'Pemasukan' : 'Pengeluaran'}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );

  const Modal = () => {
    if (!showModal) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-xl p-6 w-full max-w-md mx-4">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">
            {modalType === 'transaction' && 'Tambah Transaksi'}
            {modalType === 'account' && 'Tambah Akun'}
            {modalType === 'investment' && 'Tambah Investasi'}
          </h3>
          
          <form onSubmit={handleSubmit} className="space-y-4">
            {modalType === 'transaction' && (
              <>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Tipe</label>
                  <select 
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.type || ''}
                    onChange={(e) => setFormData({...formData, type: e.target.value})}
                    required
                  >
                    <option value="">Pilih Tipe</option>
                    <option value="income">Pemasukan</option>
                    <option value="expense">Pengeluaran</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Deskripsi</label>
                  <input 
                    type="text"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.description || ''}
                    onChange={(e) => setFormData({...formData, description: e.target.value})}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
                  <input 
                    type="text"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.category || ''}
                    onChange={(e) => setFormData({...formData, category: e.target.value})}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Jumlah</label>
                  <input 
                    type="number"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.amount || ''}
                    onChange={(e) => setFormData({...formData, amount: parseInt(e.target.value)})}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Akun</label>
                  <select 
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.account || ''}
                    onChange={(e) => setFormData({...formData, account: e.target.value})}
                    required
                  >
                    <option value="">Pilih Akun</option>
                    {accounts.map(account => (
                      <option key={account.id} value={account.name}>{account.name}</option>
                    ))}
                  </select>
                </div>
              </>
            )}

            {modalType === 'account' && (
              <>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Nama Akun</label>
                  <input 
                    type="text"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.name || ''}
                    onChange={(e) => setFormData({...formData, name: e.target.value})}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Tipe</label>
                  <select 
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.type || ''}
                    onChange={(e) => setFormData({...formData, type: e.target.value})}
                    required
                  >
                    <option value="">Pilih Tipe</option>
                    <option value="bank">Bank</option>
                    <option value="cash">Cash</option>
                    <option value="ewallet">E-Wallet</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Saldo Awal</label>
                  <input 
                    type="number"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.balance || ''}
                    onChange={(e) => setFormData({...formData, balance: parseInt(e.target.value)})}
                    required
                  />
                </div>
              </>
            )}

            {modalType === 'investment' && (
              <>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Nama</label>
                  <input 
                    type="text"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.name || ''}
                    onChange={(e) => setFormData({...formData, name: e.target.value})}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Tipe</label>
                  <select 
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.type || ''}
                    onChange={(e) => setFormData({...formData, type: e.target.value})}
                    required
                  >
                    <option value="">Pilih Tipe</option>
                    <option value="saham">Saham</option>
                    <option value="reksadana">Reksadana</option>
                    <option value="crypto">Crypto</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Jumlah/Unit</label>
                  <input 
                    type="number"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.shares || ''}
                    onChange={(e) => setFormData({...formData, shares: parseInt(e.target.value)})}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Harga Beli</label>
                  <input 
                    type="number"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.buyPrice || ''}
                    onChange={(e) => setFormData({...formData, buyPrice: parseInt(e.target.value)})}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Harga Sekarang</label>
                  <input 
                    type="number"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.currentPrice || ''}
                    onChange={(e) => setFormData({...formData, currentPrice: parseInt(e.target.value)})}
                    required
                  />
                </div>
              </>
            )}

            <div className="flex gap-3 pt-4">
              <button
                type="button"
                onClick={closeModal}
                className="flex-1 px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200"
              >
                Batal
              </button>
              <button
                type="submit"
                className="flex-1 px-4 py-2 text-white bg-blue-600 rounded-lg hover:bg-blue-700"
              >
                Simpan
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  };

  const ReportsView = () => (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-gray-800">Laporan Keuangan</h2>
        <div className="flex gap-2">
          <select className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
            <option>Bulan Ini</option>
            <option>3 Bulan Terakhir</option>
            <option>6 Bulan Terakhir</option>
            <option>1 Tahun Terakhir</option>
          </select>
          <button className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center gap-2">
            <Download className="w-4 h-4" />
            Export PDF
          </button>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <div className="flex items-center gap-3 mb-2">
            <div className="p-2 bg-blue-100 rounded-lg">
              <DollarSign className="w-5 h-5 text-blue-600" />
            </div>
            <h3 className="font-semibold text-gray-800">Net Worth</h3>
          </div>
          <p className="text-2xl font-bold text-blue-600">{formatCurrency(netWorth)}</p>
          <p className="text-sm text-green-600 mt-1">+12.5% dari bulan lalu</p>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <div className="flex items-center gap-3 mb-2">
            <div className="p-2 bg-green-100 rounded-lg">
              <TrendingUp className="w-5 h-5 text-green-600" />
            </div>
            <h3 className="font-semibold text-gray-800">Savings Rate</h3>
          </div>
          <p className="text-2xl font-bold text-green-600">65.2%</p>
          <p className="text-sm text-green-600 mt-1">+5.2% dari bulan lalu</p>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <div className="flex items-center gap-3 mb-2">
            <div className="p-2 bg-purple-100 rounded-lg">
              <PieChart className="w-5 h-5 text-purple-600" />
            </div>
            <h3 className="font-semibold text-gray-800">Investment Ratio</h3>
          </div>
          <p className="text-2xl font-bold text-purple-600">9.8%</p>
          <p className="text-sm text-red-600 mt-1">-2.1% dari bulan lalu</p>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <div className="flex items-center gap-3 mb-2">
            <div className="p-2 bg-orange-100 rounded-lg">
              <BarChart3 className="w-5 h-5 text-orange-600" />
            </div>
            <h3 className="font-semibold text-gray-800">Expense Ratio</h3>
          </div>
          <p className="text-2xl font-bold text-orange-600">34.8%</p>
          <p className="text-sm text-green-600 mt-1">-8.2% dari bulan lalu</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Tren Pengeluaran</h3>
          <div className="h-64 flex items-center justify-center bg-gray-50 rounded-lg">
            <div className="text-center">
              <BarChart3 className="w-16 h-16 text-gray-400 mx-auto mb-2" />
              <p className="text-gray-500">Chart akan tampil di sini</p>
              <p className="text-sm text-gray-400 mt-1">Integrasi dengan Chart.js atau library lainnya</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Distribusi Pengeluaran</h3>
          <div className="h-64 flex items-center justify-center bg-gray-50 rounded-lg">
            <div className="text-center">
              <PieChart className="w-16 h-16 text-gray-400 mx-auto mb-2" />
              <p className="text-gray-500">Pie Chart akan tampil di sini</p>
              <p className="text-sm text-gray-400 mt-1">Breakdown pengeluaran per kategori</p>
            </div>
          </div>
        </div>
      </div>

      {/* Detailed Analysis */}
      <div className="bg-white p-6 rounded-xl shadow-sm border">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">Analisis Detail</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h4 className="font-medium text-gray-700 mb-3">Top 5 Kategori Pengeluaran</h4>
            <div className="space-y-3">
              {[
                { category: 'Makanan', amount: 2500000, percentage: 35 },
                { category: 'Transport', amount: 1200000, percentage: 18 },
                { category: 'Hiburan', amount: 800000, percentage: 12 },
                { category: 'Belanja', amount: 600000, percentage: 9 },
                { category: 'Kesehatan', amount: 400000, percentage: 6 }
              ].map((item, index) => (
                <div key={index} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-3 h-3 bg-blue-500 rounded-full"></div>
                    <span className="text-gray-700">{item.category}</span>
                  </div>
                  <div className="text-right">
                    <div className="font-semibold text-gray-800">{formatCurrency(item.amount)}</div>
                    <div className="text-sm text-gray-500">{item.percentage}%</div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div>
            <h4 className="font-medium text-gray-700 mb-3">Performa Investasi</h4>
            <div className="space-y-3">
              {investments.map((investment, index) => {
                const gainLoss = (investment.currentPrice - investment.buyPrice) * investment.shares;
                const gainLossPercentage = ((investment.currentPrice - investment.buyPrice) / investment.buyPrice) * 100;
                
                return (
                  <div key={index} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className={`w-3 h-3 rounded-full ${gainLoss >= 0 ? 'bg-green-500' : 'bg-red-500'}`}></div>
                      <span className="text-gray-700">{investment.name}</span>
                    </div>
                    <div className="text-right">
                      <div className={`font-semibold ${gainLoss >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {gainLoss >= 0 ? '+' : ''}{formatCurrency(gainLoss)}
                      </div>
                      <div className={`text-sm ${gainLoss >= 0 ? 'text-green-500' : 'text-red-500'}`}>
                        {gainLoss >= 0 ? '+' : ''}{gainLossPercentage.toFixed(2)}%
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  const BudgetView = () => (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-gray-800">Budget Planning</h2>
        <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2">
          <PlusCircle className="w-4 h-4" />
          Tambah Budget
        </button>
      </div>

      {/* Budget Overview */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-2">Total Budget</h3>
          <p className="text-3xl font-bold text-blue-600">{formatCurrency(3800000)}</p>
          <p className="text-sm text-gray-500 mt-1">Budget bulanan</p>
        </div>
        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-2">Terpakai</h3>
          <p className="text-3xl font-bold text-orange-600">{formatCurrency(1620000)}</p>
          <p className="text-sm text-gray-500 mt-1">42.6% dari budget</p>
        </div>
        <div className="bg-white p-6 rounded-xl shadow-sm border">
          <h3 className="text-lg font-semibold text-gray-800 mb-2">Sisa</h3>
          <p className="text-3xl font-bold text-green-600">{formatCurrency(2180000)}</p>
          <p className="text-sm text-gray-500 mt-1">57.4% tersisa</p>
        </div>
      </div>

      {/* Detailed Budget */}
      <div className="bg-white rounded-xl shadow-sm border">
        <div className="p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-6">Detail Budget</h3>
          <div className="space-y-6">
            {budgets.map(budget => {
              const percentage = (budget.spent / budget.budgeted) * 100;
              const isOverBudget = percentage > 100;
              const remaining = budget.budgeted - budget.spent;
              
              return (
                <div key={budget.id} className="border border-gray-200 rounded-lg p-4">
                  <div className="flex justify-between items-start mb-3">
                    <div>
                      <h4 className="font-semibold text-gray-800">{budget.category}</h4>
                      <p className="text-sm text-gray-500 capitalize">{budget.period}</p>
                    </div>
                    <div className="text-right">
                      <div className={`text-lg font-bold ${isOverBudget ? 'text-red-600' : 'text-gray-800'}`}>
                        {formatCurrency(budget.spent)} / {formatCurrency(budget.budgeted)}
                      </div>
                      <div className={`text-sm ${isOverBudget ? 'text-red-600' : 'text-gray-600'}`}>
                        {percentage.toFixed(1)}%
                      </div>
                    </div>
                  </div>
                  
                  <div className="mb-3">
                    <div className="w-full bg-gray-200 rounded-full h-3">
                      <div 
                        className={`h-3 rounded-full transition-all duration-300 ${
                          isOverBudget ? 'bg-red-500' : percentage > 80 ? 'bg-yellow-500' : 'bg-green-500'
                        }`}
                        style={{ width: `${Math.min(percentage, 100)}%` }}
                      ></div>
                    </div>
                  </div>
                  
                  <div className="flex justify-between items-center text-sm">
                    <span className={`${remaining >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                      {remaining >= 0 ? 'Sisa: ' : 'Lebih: '}{formatCurrency(Math.abs(remaining))}
                    </span>
                    <span className="text-gray-500">
                      Hari tersisa: {30 - new Date().getDate()}
                    </span>
                  </div>
                  
                  {isOverBudget && (
                    <div className="mt-3 p-3 bg-red-50 border border-red-200 rounded-lg">
                      <p className="text-red-700 text-sm">
                        ⚠️ Budget sudah terlampaui sebesar {formatCurrency(budget.spent - budget.budgeted)}
                      </p>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Budget Tips */}
      <div className="bg-gradient-to-r from-blue-50 to-indigo-50 p-6 rounded-xl border border-blue-200">
        <h3 className="text-lg font-semibold text-blue-800 mb-3">💡 Tips Budget</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="text-blue-700">
            <p className="font-medium mb-1">Aturan 50/30/20</p>
            <p className="text-sm">50% kebutuhan, 30% keinginan, 20% tabungan</p>
          </div>
          <div className="text-blue-700">
            <p className="font-medium mb-1">Review Bulanan</p>
            <p className="text-sm">Evaluasi dan sesuaikan budget setiap bulan</p>
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center gap-3">
              <div className="bg-blue-600 p-2 rounded-lg">
                <Wallet className="w-6 h-6 text-white" />
              </div>
              <h1 className="text-xl font-bold text-gray-800">MoneyTracker</h1>
            </div>
            
            <div className="flex items-center gap-4">
              <button
                onClick={() => setShowBalances(!showBalances)}
                className="flex items-center gap-2 px-3 py-2 text-gray-600 hover:text-gray-800 rounded-lg hover:bg-gray-100"
              >
                {showBalances ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}
                <span className="text-sm">{showBalances ? 'Sembunyikan' : 'Tampilkan'}</span>
              </button>
              
              <div className="flex items-center gap-2 px-3 py-2 bg-gray-100 rounded-lg">
                <Calendar className="w-4 h-4 text-gray-600" />
                <span className="text-sm text-gray-700">12 Agustus 2025</span>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Navigation */}
      <nav className="bg-white border-b border-gray-200 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex space-x-8">
            {[
              { key: 'dashboard', label: 'Dashboard', icon: BarChart3 },
              { key: 'transactions', label: 'Transaksi', icon: DollarSign },
              { key: 'investments', label: 'Investasi', icon: TrendingUp },
              { key: 'budget', label: 'Budget', icon: PieChart },
              { key: 'reports', label: 'Laporan', icon: BarChart3 }
            ].map(tab => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`flex items-center gap-2 px-4 py-4 text-sm font-medium border-b-2 transition-colors ${
                  activeTab === tab.key
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                <tab.icon className="w-4 h-4" />
                {tab.label}
              </button>
            ))}
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'dashboard' && <DashboardView />}
        {activeTab === 'transactions' && <TransactionView />}
        {activeTab === 'investments' && <InvestmentView />}
        {activeTab === 'budget' && <BudgetView />}
        {activeTab === 'reports' && <ReportsView />}
      </main>

      <Modal />
    </div>
  );
};

export default FinanceApp;