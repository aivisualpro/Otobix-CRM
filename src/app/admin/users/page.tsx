'use client';

import { useState, useEffect, useMemo, FormEvent } from 'react';
import {
  Search,
  Plus,
  Edit2,
  Trash2,
  Download,
  X,
  User as UserIcon,
  Shield,
  Mail,
  MapPin,
  Lock,
  Phone,
  CheckCircle,
  Clock,
} from 'lucide-react';
import Table from '@/components/Table';
import GlobalImportModal from '@/components/GlobalImportModal';
import { useHeader } from '@/context/HeaderContext';

// --- Types ---
interface UserRecord {
  _id: string;
  userName: string;
  email: string;
  userRole: string;
  phoneNumber?: string;
  location?: string;
  addressList?: string[];
  allowedCities?: string[];
  approvalStatus: string;
  image?: string;
  createdAt: string;
}

// --- Components ---

// User Modal (Add/Edit)
interface UserModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: Partial<UserRecord> & { password?: string }) => void;
  editRecord: UserRecord | null;
}

const UserModal = ({ isOpen, onClose, onSubmit, editRecord }: UserModalProps) => {
  if (!isOpen) return null;

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);

    // Parse address list
    const addressRaw = formData.get('addressList') as string;
    const addressList = addressRaw
      ? addressRaw
          .split(',')
          .map((c) => c.trim())
          .filter(Boolean)
      : [];

    // Parse allowed cities
    const citiesRaw = formData.get('allowedCities') as string;
    const allowedCities = citiesRaw
      ? citiesRaw
          .split(',')
          .map((c) => c.trim())
          .filter(Boolean)
      : [];

    const userData: any = {
      userName: formData.get('userName') as string,
      email: formData.get('email') as string,
      userRole: formData.get('userRole') as string,
      phoneNumber: formData.get('phoneNumber') as string,
      location: formData.get('location') as string,
      approvalStatus: formData.get('approvalStatus') as string,
      addressList,
      allowedCities,
    };

    const password = formData.get('password') as string;
    if (password) {
      userData.password = password;
    }

    onSubmit(userData);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
      <div className="bg-white shadow-2xl w-full max-w-lg border border-gray-100 rounded-xl">
        <div className="sticky top-0 bg-white/95 backdrop-blur-sm px-6 py-4 border-b border-gray-100 flex justify-between items-center z-10 rounded-t-xl">
          <h2 className="text-lg font-bold text-slate-900">
            {editRecord ? 'Edit User' : 'Add New User'}
          </h2>
          <button onClick={onClose} className="p-2 hover:bg-gray-100 transition-colors rounded-lg">
            <X className="w-5 h-5 text-slate-500" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4 max-h-[80vh] overflow-y-auto">
          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-1">User Name</label>
            <div className="relative">
              <UserIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                name="userName"
                type="text"
                required
                className="form-input pl-9"
                defaultValue={editRecord?.userName}
                placeholder="John Doe"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1">
                Email Address
              </label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  name="email"
                  type="email"
                  required
                  className="form-input pl-9"
                  defaultValue={editRecord?.email}
                  placeholder="john@example.com"
                />
              </div>
            </div>
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1">
                Phone Number
              </label>
              <div className="relative">
                <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  name="phoneNumber"
                  type="tel"
                  className="form-input pl-9"
                  defaultValue={editRecord?.phoneNumber}
                  placeholder="1234567890"
                />
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1">Role</label>
              <div className="relative">
                <Shield className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <select
                  name="userRole"
                  className="form-input pl-9"
                  defaultValue={editRecord?.userRole || 'User'}
                >
                  <option value="Admin">Admin</option>
                  <option value="Staff">Staff</option>
                  <option value="User">User</option>
                </select>
              </div>
            </div>
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1">Status</label>
              <div className="relative">
                <CheckCircle className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <select
                  name="approvalStatus"
                  className="form-input pl-9"
                  defaultValue={editRecord?.approvalStatus || 'Pending'}
                >
                  <option value="Approved">Approved</option>
                  <option value="Pending">Pending</option>
                  <option value="Rejected">Rejected</option>
                </select>
              </div>
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-1">
              Password{' '}
              {editRecord && (
                <span className="text-gray-400 font-normal">(Leave blank to keep unchanged)</span>
              )}
            </label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                name="password"
                type="password"
                className="form-input pl-9"
                placeholder={editRecord ? '••••••••' : 'Enter password'}
                required={!editRecord}
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1">
                City/Location
              </label>
              <div className="relative">
                <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  name="location"
                  type="text"
                  className="form-input pl-9"
                  defaultValue={editRecord?.location}
                  placeholder="Kolkata"
                />
              </div>
            </div>
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1">
                Address List (Comma Sep)
              </label>
              <input
                name="addressList"
                type="text"
                className="form-input"
                defaultValue={editRecord?.addressList?.join(', ')}
                placeholder="Office, Home"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-1">
              Allowed Cities (Comma Sep)
            </label>
            <textarea
              name="allowedCities"
              className="form-input h-20 resize-none pt-2"
              defaultValue={editRecord?.allowedCities?.join(', ')}
              placeholder="Siliguri, Bhubaneswar, Patna, Gaya..."
            ></textarea>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-gray-100 mt-2">
            <button type="button" onClick={onClose} className="btn-secondary">
              Cancel
            </button>
            <button type="submit" className="btn-primary">
              {editRecord ? 'Update User' : 'Create User'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

// --- Main Page Component ---
export default function UsersPage() {
  const { setTitle, setSearchContent, setActionsContent } = useHeader();
  const [users, setUsers] = useState<UserRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingRecord, setEditingRecord] = useState<UserRecord | null>(null);
  const [isImportModalOpen, setIsImportModalOpen] = useState(false);

  // Fetch Data
  const fetchUsers = async () => {
    setLoading(true);
    try {
      const res = await fetch('/api/users', { cache: 'no-store' });
      if (res.ok) {
        const data = await res.json();
        console.log('Fetched users count:', Array.isArray(data) ? data.length : 0);
        setUsers(Array.isArray(data) ? data : []);
      }
    } catch (error) {
      console.error('Failed to fetch users', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  // Set Header
  useEffect(() => {
    setTitle('User Management');
    setSearchContent(
      <div className="relative group w-full max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search users..."
          className="w-full pl-9 pr-4 py-1.5 bg-gray-50 border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-xs rounded-lg"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>
    );
    setActionsContent(
      <div className="flex items-center gap-2">
        <button
          onClick={() => setIsImportModalOpen(true)}
          className="flex items-center justify-center w-8 h-8 text-blue-500 hover:bg-blue-50 transition-colors border border-blue-200 rounded-lg"
          title="Import Users"
        >
          <Download className="w-4 h-4" />
        </button>
        <button
          onClick={() => {
            setEditingRecord(null);
            setIsModalOpen(true);
          }}
          className="flex items-center justify-center w-8 h-8 bg-blue-500 text-white shadow-lg shadow-blue-500/20 hover:bg-blue-600 transition-colors rounded-lg"
          title="Add User"
        >
          <Plus className="w-5 h-5" />
        </button>
      </div>
    );
  }, [setTitle, setSearchContent, setActionsContent, searchTerm]);

  // Handlers
  const handleSave = async (data: any) => {
    try {
      const url = editingRecord ? `/api/users/${editingRecord._id}` : '/api/users';
      const method = editingRecord ? 'PUT' : 'POST';

      const res = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      if (res.ok) {
        fetchUsers();
        setIsModalOpen(false);
        setEditingRecord(null);
      } else {
        const err = await res.json();
        alert('Error: ' + err.error);
      }
    } catch (error) {
      alert('Failed to save user');
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this user?')) return;
    try {
      const res = await fetch(`/api/users/${id}`, { method: 'DELETE' });
      if (res.ok) fetchUsers();
    } catch (error) {
      alert('Failed to delete user');
    }
  };

  // Filter & Pagination
  const filteredUsers = useMemo(() => {
    return users.filter(
      (user) =>
        user.userName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.userRole?.toLowerCase().includes(searchTerm.toLowerCase())
    );
  }, [users, searchTerm]);

  // Columns
  const columns = [
    {
      header: 'Name',
      render: (row: UserRecord) => (
        <div className="flex items-center gap-2">
          {row.image ? (
            <img src={row.image} alt={row.userName} className="w-8 h-8 rounded-full object-cover" />
          ) : (
            <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 text-xs font-bold uppercase">
              {row.userName?.slice(0, 2)}
            </div>
          )}
          <div className="flex flex-col">
            <span className="font-medium text-slate-900">{row.userName}</span>
            <span className="text-[10px] text-slate-400">{row.location}</span>
          </div>
        </div>
      ),
    },
    {
      header: 'Email & Phone',
      render: (row: UserRecord) => (
        <div className="flex flex-col">
          <span className="text-slate-600 text-xs">{row.email}</span>
          <span className="text-slate-400 text-[10px] font-mono">{row.phoneNumber}</span>
        </div>
      ),
    },
    {
      header: 'Role',
      render: (row: UserRecord) => (
        <span
          className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wide 
          ${row.userRole === 'Admin' ? 'bg-purple-100 text-purple-700' : 'bg-gray-100 text-gray-600'}`}
        >
          {row.userRole}
        </span>
      ),
    },
    {
      header: 'Allowed Cities',
      render: (row: UserRecord) => (
        <div className="flex flex-wrap gap-1 max-w-[200px]">
          {row.allowedCities?.slice(0, 3).map((city, i) => (
            <span
              key={i}
              className="px-1.5 py-0.5 bg-blue-50 text-blue-600 text-[10px] rounded border border-blue-100"
            >
              {city}
            </span>
          ))}
          {row.allowedCities && row.allowedCities.length > 3 && (
            <span className="text-[10px] text-gray-400">+{row.allowedCities.length - 3}</span>
          )}
        </div>
      ),
    },
    {
      header: 'Status',
      render: (row: UserRecord) => {
        let colors = 'bg-gray-100 text-gray-600';
        if (row.approvalStatus === 'Approved') colors = 'bg-green-100 text-green-700';
        if (row.approvalStatus === 'Rejected') colors = 'bg-red-100 text-red-700';
        return (
          <span
            className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wide ${colors}`}
          >
            {row.approvalStatus}
          </span>
        );
      },
    },
    {
      header: 'Actions',
      align: 'right' as const,
      render: (row: UserRecord) => (
        <div className="flex items-center justify-end gap-1">
          <button
            onClick={() => {
              setEditingRecord(row);
              setIsModalOpen(true);
            }}
            className="p-1.5 text-slate-400 hover:text-blue-500 hover:bg-blue-50 rounded transition-colors"
          >
            <Edit2 className="w-3.5 h-3.5" />
          </button>
          <button
            onClick={() => handleDelete(row._id)}
            className="p-1.5 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded transition-colors"
          >
            <Trash2 className="w-3.5 h-3.5" />
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="h-full flex flex-col bg-white overflow-hidden">
      <div className="flex-1 overflow-hidden">
        <Table
          columns={columns}
          data={filteredUsers}
          keyField="_id"
          pagination={{
            currentPage: 1,
            totalPages: 1,
            totalItems: filteredUsers.length,
            startIndex: 0,
            endIndex: filteredUsers.length,
            onNext: () => {},
            onPrev: () => {},
            onSetPage: () => {},
            canNext: false,
            canPrev: false,
          }}
        />
      </div>

      <UserModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSubmit={handleSave}
        editRecord={editingRecord}
      />

      <GlobalImportModal
        isOpen={isImportModalOpen}
        onClose={() => setIsImportModalOpen(false)}
        endpoint="/api/users/import"
        title="Import Users"
        onSuccess={() => {
          fetchUsers();
          setTimeout(() => setIsImportModalOpen(false), 1500);
        }}
      />
    </div>
  );
}
