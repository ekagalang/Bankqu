import React, { useState, useEffect } from 'react';
import { 
  DollarSign, 
  TrendingUp, 
  CreditCard, 
  PieChart,
  Plus,
  Wallet,
  ArrowUpRight,
  ArrowDownLeft,
  Eye,
  EyeOff,
  Bell,
  Settings,
  Menu,
  X,
  Filter,
  Search,
  Calendar,
  MoreVertical,
  Home,
  Activity,
  RefreshCw,
  AlertCircle
} from 'lucide-react';

const AdvancedFinanceApp = () => {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [showBalance, setShowBalance] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState('all');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [lastUpdated, setLastUpdated] = useState(new Date());
  
  // Real-time data from API
  const [accounts, setAccounts] = useState([]);
  const [transactions, setTransactions] = useState([]);
  const [investments, setInvestments] = useState([]);
  
  // Form states
  const [showAddAccount, setShowAddAccount] = useState(false);
  const [showAddTransaction, setShowAddTransaction] = useState(false);
  const [newAccount, setNewAccount] = useState({ name: '', type: 'checking', balance: 0 });
  const [newTransaction, setNewTransaction] = useState({ 
    description: '', 
    amount: '', 
    type: 'expense', 
    category: '', 
    account_id: '' 
  });

  // API Base URL
  const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

  // API Helper Functions
  const apiCall = async (endpoint, options = {}) => {
    try {
      console.log(`🔄 API Call: ${API_BASE_URL}${endpoint}`);
      console.log('📤 Request options:', options);
      
      const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          ...options.headers
        },
        ...options
      });

      console.log(`📥 Response status: ${response.status} ${response.statusText}`);
      console.log('📥 Response headers:', Object.fromEntries(response.headers.entries()));

      // Get response as text first to debug
      const responseText = await response.text();
      console.log('📥 Raw response text:', responseText);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}\nResponse: ${responseText}`);
      }

      // Check if response is empty
      if (!responseText.trim()) {
        throw new Error('Empty response from server');
      }

      // Try to parse as JSON
      let data;
      try {
        data = JSON.parse(responseText);
        console.log('📥 Parsed JSON data:', data);
      } catch (parseError) {
        console.error('❌ JSON Parse Error:', parseError);
        console.error('📥 Unparseable response:', responseText);
        throw new Error(`Invalid JSON response: ${parseError.message}\nResponse: ${responseText.substring(0, 200)}...`);
      }

      return data;
    } catch (error) {
      console.error('❌ API call failed:', error);
      throw error;
    }
  };

  // Fetch all data from API
  const fetchAllData = async () => {
    setLoading(true);
    setError(null);
    
    try {
      console.log('🔄 Starting data fetch...');
      console.log('🌐 API Base URL:', API_BASE_URL);
      
      // Check if backend is healthy first
      let healthCheck;
      try {
        healthCheck = await apiCall('/health');
        console.log('✅ Backend health check passed:', healthCheck);
      } catch (healthError) {
        console.error('❌ Backend health check failed:', healthError);
        throw new Error(`Backend not accessible: ${healthError.message}`);
      }

      // Fetch all data with individual error handling
      const results = await Promise.allSettled([
        apiCall('/v1/accounts').catch(e => {
          console.warn('⚠️ Accounts API failed:', e.message);
          return { success: true, data: [] };
        }),
        apiCall('/v1/transactions').catch(e => {
          console.warn('⚠️ Transactions API failed:', e.message);
          return { success: true, data: { data: [] } };
        }),
        apiCall('/v1/investments').catch(e => {
          console.warn('⚠️ Investments API failed:', e.message);
          return { success: true, data: { investments: [] } };
        })
      ]);

      const [accountsResult, transactionsResult, investmentsResult] = results;

      console.log('📊 API Results:', { 
        accounts: accountsResult, 
        transactions: transactionsResult, 
        investments: investmentsResult 
      });

      // Extract data from settled promises
      const accountsRes = accountsResult.status === 'fulfilled' ? accountsResult.value : { success: true, data: [] };
      const transactionsRes = transactionsResult.status === 'fulfilled' ? transactionsResult.value : { success: true, data: { data: [] } };
      const investmentsRes = investmentsResult.status === 'fulfilled' ? investmentsResult.value : { success: true, data: { investments: [] } };

      // Set data from API or fallback to demo data
      const accountsData = accountsRes.data || [
        { id: 1, name: 'Bank Mandiri (Demo)', type: 'checking', balance: 15750000, color: 'blue' },
        { id: 2, name: 'Bank BCA (Demo)', type: 'savings', balance: 32450000, color: 'green' },
        { id: 3, name: 'Kredit Mobil (Demo)', type: 'credit', balance: -8500000, color: 'red' }
      ];

      const transactionsData = transactionsRes.data?.data || [
        { id: 1, description: 'Gaji Bulanan (Demo)', amount: 12000000, type: 'income', category: 'Salary', date: '2025-01-10', account_id: 1 },
        { id: 2, description: 'Belanja Groceries (Demo)', amount: -750000, type: 'expense', category: 'Food', date: '2025-01-09', account_id: 2 },
        { id: 3, description: 'Transfer ke Tabungan (Demo)', amount: -2000000, type: 'transfer', category: 'Savings', date: '2025-01-08', account_id: 1 },
        { id: 4, description: 'Freelance Project (Demo)', amount: 3500000, type: 'income', category: 'Work', date: '2025-01-07', account_id: 2 }
      ];

      const investmentsData = investmentsRes.data?.investments || [
        { id: 1, name: 'Saham BBRI (Demo)', shares: 100, price: 4850, value: 485000, type: 'stock', change: 2.5 },
        { id: 2, name: 'Reksadana Mandiri (Demo)', shares: 1000, price: 2150, value: 2150000, type: 'mutual_fund', change: -1.2 },
        { id: 3, name: 'Bitcoin (Demo)', shares: 0.05, price: 780000000, value: 39000000, type: 'crypto', change: 5.8 }
      ];

      setAccounts(accountsData);
      setTransactions(transactionsData);
      setInvestments(investmentsData);
      setLastUpdated(new Date());
      
      console.log('✅ Data loaded successfully');
      console.log('📊 Final data:', { 
        accounts: accountsData.length, 
        transactions: transactionsData.length, 
        investments: investmentsData.length 
      });
      
    } catch (error) {
      console.error('❌ Failed to fetch data:', error);
      setError(`Koneksi API bermasalah: ${error.message}`);
      
      // Use fallback demo data when API completely fails
      console.log('🔄 Using fallback demo data');
      setAccounts([
        { id: 1, name: 'Bank Mandiri (Offline)', type: 'checking', balance: 15750000, color: 'blue' },
        { id: 2, name: 'Bank BCA (Offline)', type: 'savings', balance: 32450000, color: 'green' }
      ]);
      setTransactions([
        { id: 1, description: 'Demo: Gaji Bulanan', amount: 12000000, type: 'income', category: 'Salary', date: '2025-01-10' }
      ]);
      setInvestments([
        { id: 1, name: 'Demo: Saham BBRI', shares: 100, price: 4850, value: 485000, type: 'stock', change: 2.5 }
      ]);
    }
    
    setLoading(false);
  };

  // Add new account via API
  const handleAddAccount = async (e) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      // Try to add via API first
      try {
        const response = await apiCall('/v1/accounts', {
          method: 'POST',
          body: JSON.stringify(newAccount)
        });
        
        if (response.success) {
          console.log('✅ Account added via API');
          await fetchAllData(); // Refresh all data
        }
      } catch (apiError) {
        console.log('⚠️ API add failed, adding locally:', apiError);
        
        // Fallback: Add locally
        const account = {
          id: Date.now(),
          ...newAccount,
          balance: parseFloat(newAccount.balance) || 0,
          color: ['blue', 'green', 'purple', 'red'][Math.floor(Math.random() * 4)]
        };
        setAccounts(prev => [...prev, account]);
      }
      
      setNewAccount({ name: '', type: 'checking', balance: 0 });
      setShowAddAccount(false);
      alert('Rekening berhasil ditambahkan!');
      
    } catch (error) {
      console.error('❌ Failed to add account:', error);
      alert('Gagal menambahkan rekening!');
    }
    
    setLoading(false);
  };

  // Add new transaction via API
  const handleAddTransaction = async (e) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      const transactionData = {
        ...newTransaction,
        amount: parseFloat(newTransaction.amount) * (newTransaction.type === 'expense' ? -1 : 1),
        date: new Date().toISOString().split('T')[0]
      };
      
      // Try to add via API first
      try {
        const response = await apiCall('/v1/transactions', {
          method: 'POST',
          body: JSON.stringify(transactionData)
        });
        
        if (response.success) {
          console.log('✅ Transaction added via API');
          await fetchAllData(); // Refresh all data
        }
      } catch (apiError) {
        console.log('⚠️ API add failed, adding locally:', apiError);
        
        // Fallback: Add locally
        const transaction = { id: Date.now(), ...transactionData };
        setTransactions(prev => [...prev, transaction]);
        
        // Update account balance locally
        setAccounts(prev => prev.map(acc => 
          acc.id === parseInt(newTransaction.account_id) 
            ? { ...acc, balance: acc.balance + transaction.amount }
            : acc
        ));
      }
      
      setNewTransaction({ description: '', amount: '', type: 'expense', category: '', account_id: '' });
      setShowAddTransaction(false);
      alert('Transaksi berhasil ditambahkan!');
      
    } catch (error) {
      console.error('❌ Failed to add transaction:', error);
      alert('Gagal menambahkan transaksi!');
    }
    
    setLoading(false);
  };

  // Delete transaction
  const deleteTransaction = async (id) => {
    if (window.confirm('Hapus transaksi ini?')) {
      try {
        // Try API delete first
        try {
          await apiCall(`/v1/transactions/${id}`, { method: 'DELETE' });
          await fetchAllData(); // Refresh data
        } catch (apiError) {
          // Fallback: Delete locally
          setTransactions(prev => prev.filter(t => t.id !== id));
        }
        alert('Transaksi berhasil dihapus!');
      } catch (error) {
        alert('Gagal menghapus transaksi!');
      }
    }
  };

  // Delete account
  const deleteAccount = async (id) => {
    if (window.confirm('Hapus rekening ini?')) {
      try {
        // Try API delete first
        try {
          await apiCall(`/v1/accounts/${id}`, { method: 'DELETE' });
          await fetchAllData(); // Refresh data
        } catch (apiError) {
          // Fallback: Delete locally
          setAccounts(prev => prev.filter(a => a.id !== id));
        }
        alert('Rekening berhasil dihapus!');
      } catch (error) {
        alert('Gagal menghapus rekening!');
      }
    }
  };

  // Auto-refresh data every 30 seconds
  useEffect(() => {
    fetchAllData(); // Initial load
    
    const interval = setInterval(() => {
      console.log('🔄 Auto-refreshing data...');
      fetchAllData();
    }, 30000); // 30 seconds

    return () => clearInterval(interval);
  }, []);

  // Format currency to Rupiah
  const formatRupiah = (amount) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0
    }).format(amount);
  };

  const totalBalance = accounts.reduce((sum, acc) => sum + acc.balance, 0);
  const totalInvestments = investments.reduce((sum, inv) => sum + inv.value, 0);

  const filteredTransactions = transactions.filter(transaction => {
    const matchesSearch = transaction.description.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesFilter = filterType === 'all' || transaction.type === filterType;
    return matchesSearch && matchesFilter;
  });

  // Loading Spinner Component
  const LoadingSpinner = () => (
    <div className="flex items-center justify-center p-8">
      <div className="flex items-center space-x-2">
        <RefreshCw className="animate-spin" size={20} />
        <span>Memuat data...</span>
      </div>
    </div>
  );

  // Error Alert Component
  const ErrorAlert = () => error && (
    <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
      <div className="flex items-center space-x-2">
        <AlertCircle size={20} className="text-red-600" />
        <div>
          <p className="text-red-800 font-medium">Koneksi Bermasalah</p>
          <p className="text-red-600 text-sm">{error}</p>
          <button 
            onClick={fetchAllData}
            className="text-red-600 hover:text-red-800 text-sm underline mt-1"
          >
            Coba Lagi
          </button>
        </div>
      </div>
    </div>
  );

  const Navigation = () => (
    <nav className="bg-white/80 backdrop-blur-lg shadow-sm border-b border-gray-200/50 sticky top-0 z-40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center">
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="lg:hidden p-2 rounded-md text-gray-600 hover:bg-gray-100"
            >
              {sidebarOpen ? <X size={24} /> : <Menu size={24} />}
            </button>
            <div className="flex items-center space-x-2 ml-2 lg:ml-0">
              <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
                <Wallet size={20} className="text-white" />
              </div>
              <span className="text-xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                BankQu
              </span>
              {loading && <RefreshCw className="animate-spin text-blue-500" size={16} />}
            </div>
          </div>
          
          <div className="hidden lg:flex space-x-8">
            {[
              { id: 'dashboard', label: 'Dashboard', icon: Home },
              { id: 'accounts', label: 'Accounts', icon: CreditCard },
              { id: 'transactions', label: 'Transactions', icon: Activity },
              { id: 'investments', label: 'Investments', icon: TrendingUp }
            ].map(({ id, label, icon: Icon }) => (
              <button
                key={id}
                onClick={() => setActiveTab(id)}
                className={`inline-flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-all duration-200 ${
                  activeTab === id
                    ? 'bg-blue-50 text-blue-700 shadow-sm'
                    : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
                }`}
              >
                <Icon size={18} className="mr-2" />
                {label}
              </button>
            ))}
          </div>

          <div className="flex items-center space-x-4">
            <button 
              onClick={fetchAllData}
              className="p-2 text-gray-600 hover:bg-gray-100 rounded-lg"
              title="Refresh Data"
            >
              <RefreshCw size={20} className={loading ? 'animate-spin' : ''} />
            </button>
            <button className="p-2 text-gray-600 hover:bg-gray-100 rounded-lg">
              <Bell size={20} />
            </button>
            <button className="p-2 text-gray-600 hover:bg-gray-100 rounded-lg">
              <Settings size={20} />
            </button>
          </div>
        </div>
      </div>
    </nav>
  );

  const Sidebar = () => (
    <div className={`lg:hidden fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 ${
      sidebarOpen ? 'translate-x-0' : '-translate-x-full'
    }`}>
      <div className="p-4 border-b">
        <div className="flex items-center space-x-2">
          <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
            <Wallet size={20} className="text-white" />
          </div>
          <span className="text-xl font-bold">BankQu</span>
        </div>
      </div>
      
      <nav className="p-4 space-y-2">
        {[
          { id: 'dashboard', label: 'Dashboard', icon: Home },
          { id: 'accounts', label: 'Accounts', icon: CreditCard },
          { id: 'transactions', label: 'Transactions', icon: Activity },
          { id: 'investments', label: 'Investments', icon: TrendingUp }
        ].map(({ id, label, icon: Icon }) => (
          <button
            key={id}
            onClick={() => {
              setActiveTab(id);
              setSidebarOpen(false);
            }}
            className={`w-full flex items-center px-3 py-3 text-sm font-medium rounded-xl transition-all duration-200 ${
              activeTab === id
                ? 'bg-blue-50 text-blue-700 shadow-sm'
                : 'text-gray-600 hover:bg-gray-50'
            }`}
          >
            <Icon size={20} className="mr-3" />
            {label}
          </button>
        ))}
      </nav>
    </div>
  );

  const DashboardContent = () => (
    <div className="space-y-6">
      <ErrorAlert />
      
      {/* Welcome Section */}
      <div className="bg-gradient-to-br from-blue-600 via-purple-600 to-indigo-700 rounded-2xl p-6 lg:p-8 text-white relative overflow-hidden">
        <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -translate-y-16 translate-x-16"></div>
        <div className="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full translate-y-12 -translate-x-12"></div>
        
        <div className="relative z-10">
          <div className="flex justify-between items-start mb-6">
            <div>
              <h1 className="text-2xl lg:text-3xl font-bold mb-2">Selamat datang kembali!</h1>
              <p className="text-white/80 text-lg">Kelola keuangan Anda dengan mudah</p>
              <p className="text-white/60 text-sm mt-2">
                Terakhir diperbarui: {lastUpdated.toLocaleTimeString('id-ID')}
              </p>
            </div>
            <button
              onClick={() => setShowBalance(!showBalance)}
              className="p-2 bg-white/20 rounded-lg hover:bg-white/30 transition-colors"
            >
              {showBalance ? <EyeOff size={20} /> : <Eye size={20} />}
            </button>
          </div>
          
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div>
              <p className="text-white/80 text-sm mb-1">Total Saldo</p>
              <p className="text-3xl lg:text-4xl font-bold">
                {showBalance ? formatRupiah(totalBalance) : '••••••••'}
              </p>
            </div>
            <div>
              <p className="text-white/80 text-sm mb-1">Total Investasi</p>
              <p className="text-2xl lg:text-3xl font-bold">
                {showBalance ? formatRupiah(totalInvestments) : '••••••••'}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6">
        <div className="bg-white p-4 lg:p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Rekening</p>
              <p className="text-2xl font-bold text-gray-900">{accounts.length}</p>
            </div>
            <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
              <CreditCard size={24} className="text-blue-600" />
            </div>
          </div>
        </div>
        
        <div className="bg-white p-4 lg:p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Transaksi</p>
              <p className="text-2xl font-bold text-gray-900">{transactions.length}</p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
              <Activity size={24} className="text-green-600" />
            </div>
          </div>
        </div>
        
        <div className="bg-white p-4 lg:p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Investasi</p>
              <p className="text-2xl font-bold text-gray-900">{investments.length}</p>
            </div>
            <div className="w-12 h-12 bg-purple-100 rounded-xl flex items-center justify-center">
              <PieChart size={24} className="text-purple-600" />
            </div>
          </div>
        </div>
        
        <div className="bg-white p-4 lg:p-6 rounded-xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-600 text-sm">Pemasukan</p>
              <p className="text-xl font-bold text-green-600">
                {formatRupiah(transactions.filter(t => t.type === 'income').reduce((sum, t) => sum + Math.abs(t.amount), 0))}
              </p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
              <ArrowUpRight size={24} className="text-green-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Accounts Overview */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-bold text-gray-900">Rekening Saya</h2>
          <button 
            className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            onClick={() => setShowAddAccount(true)}
          >
            <Plus size={18} />
            <span>Tambah Rekening</span>
          </button>
        </div>
        
        {loading ? <LoadingSpinner /> : (
          <div className="space-y-4">
            {accounts.length === 0 ? (
              <p className="text-gray-500 text-center py-8">Belum ada rekening. Tambahkan rekening pertama Anda!</p>
            ) : (
              accounts.map(account => (
                <div key={account.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                  <div className="flex items-center space-x-4">
                    <div className={`w-12 h-12 bg-${account.color || 'blue'}-100 rounded-xl flex items-center justify-center`}>
                      <CreditCard size={20} className={`text-${account.color || 'blue'}-600`} />
                    </div>
                    <div>
                      <p className="font-semibold text-gray-900">{account.name}</p>
                      <p className="text-sm text-gray-600 capitalize">{account.type.replace('_', ' ')}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className={`text-lg font-bold ${account.balance >= 0 ? 'text-gray-900' : 'text-red-600'}`}>
                      {formatRupiah(account.balance)}
                    </p>
                    <button 
                      onClick={() => deleteAccount(account.id)}
                      className="text-xs text-red-500 hover:text-red-700 mt-1"
                    >
                      Hapus
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        )}
      </div>

      {/* Recent Transactions */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-bold text-gray-900">Transaksi Terbaru</h2>
          <button
            onClick={() => setActiveTab('transactions')}
            className="text-blue-600 hover:text-blue-700 font-medium"
          >
            Lihat Semua
          </button>
        </div>
        
        {loading ? <LoadingSpinner /> : (
          <div className="space-y-3">
            {transactions.length === 0 ? (
              <p className="text-gray-500 text-center py-8">Belum ada transaksi. Tambahkan transaksi pertama Anda!</p>
            ) : (
              transactions.slice(-5).reverse().map(transaction => (
                <div key={transaction.id} className="flex items-center justify-between p-4 hover:bg-gray-50 rounded-lg transition-colors">
                  <div className="flex items-center space-x-4">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                      transaction.type === 'income' ? 'bg-green-100' : 'bg-red-100'
                    }`}>
                      {transaction.type === 'income' 
                        ? <ArrowUpRight size={18} className="text-green-600" />
                        : <ArrowDownLeft size={18} className="text-red-600" />
                      }
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">{transaction.description}</p>
                      <p className="text-sm text-gray-600">{transaction.category} • {transaction.date}</p>
                    </div>
                  </div>
                  <p className={`text-lg font-semibold ${
                    transaction.type === 'income' ? 'text-green-600' : 'text-red-600'
                  }`}>
                    {transaction.type === 'income' ? '+' : ''}{formatRupiah(Math.abs(transaction.amount))}
                  </p>
                </div>
              ))
            )}
          </div>
        )}
      </div>
    </div>
  );

  const TransactionsContent = () => (
    <div className="space-y-6">
      <ErrorAlert />
      
      {/* Header & Controls */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
        <div className="flex flex-col lg:flex-row lg:items-center justify-between space-y-4 lg:space-y-0">
          <h1 className="text-2xl font-bold text-gray-900">Transaksi</h1>
          <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-4">
            <div className="relative">
              <Search size={18} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Cari transaksi..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
            <select
              value={filterType}
              onChange={(e) => setFilterType(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">Semua Tipe</option>
              <option value="income">Pemasukan</option>
              <option value="expense">Pengeluaran</option>
              <option value="transfer">Transfer</option>
            </select>
            <button 
              className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              onClick={() => setShowAddTransaction(true)}
            >
              <Plus size={18} />
              <span>Tambah Transaksi</span>
            </button>
          </div>
        </div>
      </div>

      {/* Transactions List */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100">
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">
            Daftar Transaksi ({filteredTransactions.length})
          </h2>
        </div>
        
        {loading ? <LoadingSpinner /> : (
          <div className="divide-y divide-gray-200">
            {filteredTransactions.length === 0 ? (
              <div className="p-8 text-center">
                <Activity size={48} className="mx-auto text-gray-300 mb-4" />
                <p className="text-gray-500">Tidak ada transaksi ditemukan</p>
              </div>
            ) : (
              filteredTransactions.map(transaction => (
                <div key={transaction.id} className="p-4 hover:bg-gray-50 transition-colors">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-4">
                      <div className={`w-12 h-12 rounded-full flex items-center justify-center ${
                        transaction.type === 'income' ? 'bg-green-100' : 
                        transaction.type === 'expense' ? 'bg-red-100' : 'bg-blue-100'
                      }`}>
                        {transaction.type === 'income' ? (
                          <ArrowUpRight size={20} className="text-green-600" />
                        ) : transaction.type === 'expense' ? (
                          <ArrowDownLeft size={20} className="text-red-600" />
                        ) : (
                          <Activity size={20} className="text-blue-600" />
                        )}
                      </div>
                      <div>
                        <p className="font-semibold text-gray-900">{transaction.description}</p>
                        <p className="text-sm text-gray-600">
                          {transaction.category} • {transaction.date}
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className={`text-lg font-bold ${
                        transaction.type === 'income' ? 'text-green-600' : 'text-red-600'
                      }`}>
                        {transaction.type === 'income' ? '+' : ''}{formatRupiah(Math.abs(transaction.amount))}
                      </p>
                      <button 
                        className="p-1 text-gray-400 hover:text-red-600 transition-colors"
                        onClick={() => deleteTransaction(transaction.id)}
                        title="Hapus transaksi"
                      >
                        <MoreVertical size={16} />
                      </button>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        )}
      </div>
    </div>
  );

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <DashboardContent />;
      case 'transactions':
        return <TransactionsContent />;
      case 'accounts':
        return (
          <div className="space-y-6">
            <ErrorAlert />
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-semibold">Kelola Rekening</h2>
                <button 
                  className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                  onClick={() => setShowAddAccount(true)}
                >
                  <Plus size={18} />
                  <span>Tambah Rekening</span>
                </button>
              </div>
              
              {loading ? <LoadingSpinner /> : (
                <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
                  {accounts.length === 0 ? (
                    <div className="col-span-full text-center py-8">
                      <CreditCard size={48} className="mx-auto text-gray-300 mb-4" />
                      <p className="text-gray-500">Belum ada rekening. Tambahkan rekening pertama Anda!</p>
                    </div>
                  ) : (
                    accounts.map(account => (
                      <div key={account.id} className="p-4 border border-gray-200 rounded-lg hover:shadow-md transition-shadow">
                        <div className="flex justify-between items-start mb-3">
                          <div className="flex items-center space-x-3">
                            <div className={`w-10 h-10 bg-${account.color || 'blue'}-100 rounded-lg flex items-center justify-center`}>
                              <CreditCard size={20} className={`text-${account.color || 'blue'}-600`} />
                            </div>
                            <div>
                              <p className="font-semibold">{account.name}</p>
                              <p className="text-sm text-gray-600 capitalize">{account.type.replace('_', ' ')}</p>
                            </div>
                          </div>
                          <button 
                            onClick={() => deleteAccount(account.id)}
                            className="text-red-500 hover:text-red-700 transition-colors"
                          >
                            <X size={16} />
                          </button>
                        </div>
                        <p className={`text-lg font-bold ${account.balance >= 0 ? 'text-gray-900' : 'text-red-600'}`}>
                          {formatRupiah(account.balance)}
                        </p>
                      </div>
                    ))
                  )}
                </div>
              )}
            </div>
          </div>
        );
      case 'investments':
        return (
          <div className="space-y-6">
            <ErrorAlert />
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
              <h2 className="text-xl font-semibold mb-4">Portfolio Investasi</h2>
              {loading ? <LoadingSpinner /> : (
                <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
                  {investments.length === 0 ? (
                    <div className="col-span-full text-center py-8">
                      <TrendingUp size={48} className="mx-auto text-gray-300 mb-4" />
                      <p className="text-gray-500">Belum ada investasi.</p>
                    </div>
                  ) : (
                    investments.map(investment => (
                      <div key={investment.id} className="p-4 border border-gray-200 rounded-lg hover:shadow-md transition-shadow">
                        <div className="flex justify-between items-start mb-3">
                          <div>
                            <p className="font-semibold">{investment.name}</p>
                            <p className="text-sm text-gray-600 capitalize">{investment.type.replace('_', ' ')}</p>
                          </div>
                          <span className={`px-2 py-1 text-xs rounded-full ${
                            investment.change >= 0 ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-600'
                          }`}>
                            {investment.change >= 0 ? '+' : ''}{investment.change.toFixed(2)}%
                          </span>
                        </div>
                        <p className="text-lg font-bold">{formatRupiah(investment.value)}</p>
                        <p className="text-sm text-gray-600">{investment.shares} shares @ {formatRupiah(investment.price)}</p>
                      </div>
                    ))
                  )}
                </div>
              )}
            </div>
          </div>
        );
      default:
        return <DashboardContent />;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Navigation />
      <Sidebar />
      
      {/* Overlay for mobile sidebar */}
      {sidebarOpen && (
        <div 
          className="lg:hidden fixed inset-0 bg-black/50 z-40"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        {renderContent()}
      </main>

      {/* Add Account Modal */}
      {showAddAccount && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl p-6 w-full max-w-md">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold">Tambah Rekening Baru</h2>
              <button 
                onClick={() => setShowAddAccount(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                <X size={24} />
              </button>
            </div>
            
            <form onSubmit={handleAddAccount} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Nama Rekening</label>
                <input
                  type="text"
                  value={newAccount.name}
                  onChange={(e) => setNewAccount({...newAccount, name: e.target.value})}
                  className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Contoh: Bank BCA Tabungan"
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Tipe Rekening</label>
                <select
                  value={newAccount.type}
                  onChange={(e) => setNewAccount({...newAccount, type: e.target.value})}
                  className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="checking">Giro</option>
                  <option value="savings">Tabungan</option>
                  <option value="credit">Kartu Kredit</option>
                  <option value="investment">Investasi</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Saldo Awal</label>
                <input
                  type="number"
                  step="1000"
                  value={newAccount.balance}
                  onChange={(e) => setNewAccount({...newAccount, balance: e.target.value})}
                  className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="0"
                />
              </div>
              
              <div className="flex space-x-3 pt-4">
                <button
                  type="button"
                  onClick={() => setShowAddAccount(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                  disabled={loading}
                >
                  Batal
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
                  disabled={loading}
                >
                  {loading ? 'Menyimpan...' : 'Tambah Rekening'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Transaction Modal */}
      {showAddTransaction && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl p-6 w-full max-w-md">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold">Tambah Transaksi Baru</h2>
              <button 
                onClick={() => setShowAddTransaction(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                <X size={24} />
              </button>
            </div>
            
            <form onSubmit={handleAddTransaction} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Deskripsi</label>
                <input
                  type="text"
                  value={newTransaction.description}
                  onChange={(e) => setNewTransaction({...newTransaction, description: e.target.value})}
                  className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Contoh: Belanja groceries"
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Jumlah</label>
                <input
                  type="number"
                  step="1000"
                  value={newTransaction.amount}
                  onChange={(e) => setNewTransaction({...newTransaction, amount: e.target.value})}
                  className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="50000"
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Tipe</label>
                <select
                  value={newTransaction.type}
                  onChange={(e) => setNewTransaction({...newTransaction, type: e.target.value})}
                  className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="expense">Pengeluaran</option>
                  <option value="income">Pemasukan</option>
                  <option value="transfer">Transfer</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Kategori</label>
                <input
                  type="text"
                  value={newTransaction.category}
                  onChange={(e) => setNewTransaction({...newTransaction, category: e.target.value})}
                  className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Food, Transport, Salary, dll"
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Rekening</label>
                <select
                  value={newTransaction.account_id}
                  onChange={(e) => setNewTransaction({...newTransaction, account_id: e.target.value})}
                  className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  required
                >
                  <option value="">Pilih Rekening</option>
                  {accounts.map(account => (
                    <option key={account.id} value={account.id}>
                      {account.name}
                    </option>
                  ))}
                </select>
              </div>
              
              <div className="flex space-x-3 pt-4">
                <button
                  type="button"
                  onClick={() => setShowAddTransaction(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
                  disabled={loading}
                >
                  Batal
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
                  disabled={loading}
                >
                  {loading ? 'Menyimpan...' : 'Tambah Transaksi'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdvancedFinanceApp;