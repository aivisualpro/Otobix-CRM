'use client';

import { useState, useEffect, useMemo, FormEvent, useCallback } from 'react';
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
  dealershipName?: string;
  entityType?: string;
  primaryContactPerson?: string;
  primaryContactNumber?: string;
  secondaryContactPerson?: string;
  secondaryContactNumber?: string;
  addressList?: string[];
  approvalStatus: string;
  rejectionComment?: string;
  image?: string;
  isStaff?: boolean;
  assignedKam?: string;
  allowedCities?: string[];
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

    const addressRaw = formData.get('addressList') as string;
    const addressList = addressRaw
      ? addressRaw
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
      dealershipName: formData.get('dealershipName') as string,
      entityType: formData.get('entityType') as string,
      primaryContactPerson: formData.get('primaryContactPerson') as string,
      primaryContactNumber: formData.get('primaryContactNumber') as string,
      secondaryContactPerson: formData.get('secondaryContactPerson') as string,
      secondaryContactNumber: formData.get('secondaryContactNumber') as string,
      approvalStatus: formData.get('approvalStatus') as string,
      rejectionComment: formData.get('rejectionComment') as string,
      isStaff: formData.get('isStaff') === 'true',
      addressList,
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
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 flex items-center gap-1">
                User Name <span className="text-red-500">*</span>
              </label>
              <input
                name="userName"
                type="text"
                required
                className="form-input"
                defaultValue={editRecord?.userName}
                placeholder="e.g. dealertwo"
              />
            </div>
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5 flex items-center gap-1">
                Email Address <span className="text-red-500">*</span>
              </label>
              <input
                name="email"
                type="email"
                required
                className="form-input"
                defaultValue={editRecord?.email}
                placeholder="e.g. dealer@gmail.com"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Dealership Name</label>
              <input
                name="dealershipName"
                type="text"
                className="form-input"
                defaultValue={editRecord?.dealershipName}
                placeholder="Enter dealership"
              />
            </div>
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Entity Type</label>
              <input
                name="entityType"
                type="text"
                className="form-input"
                defaultValue={editRecord?.entityType}
                placeholder="e.g. HUF"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Phone Number</label>
              <input
                name="phoneNumber"
                type="tel"
                className="form-input"
                defaultValue={editRecord?.phoneNumber}
                placeholder="Enter phone"
              />
            </div>
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">City/Location</label>
              <input
                name="location"
                type="text"
                className="form-input"
                defaultValue={editRecord?.location}
                placeholder="Enter city"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Role</label>
              <select
                name="userRole"
                className="form-input"
                defaultValue={editRecord?.userRole || 'User'}
              >
                <option value="Admin">Admin</option>
                <option value="Staff">Staff</option>
                <option value="Dealer">Dealer</option>
                <option value="User">User</option>
              </select>
            </div>
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Is Staff?</label>
              <select
                name="isStaff"
                className="form-input"
                defaultValue={editRecord?.isStaff ? 'true' : 'false'}
              >
                <option value="false">No</option>
                <option value="true">Yes</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">P. Contact Person</label>
              <input
                name="primaryContactPerson"
                type="text"
                className="form-input"
                defaultValue={editRecord?.primaryContactPerson}
                placeholder="Primary name"
              />
            </div>
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">P. Contact Number</label>
              <input
                name="primaryContactNumber"
                type="text"
                className="form-input"
                defaultValue={editRecord?.primaryContactNumber}
                placeholder="Primary number"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">S. Contact Person</label>
              <input
                name="secondaryContactPerson"
                type="text"
                className="form-input"
                defaultValue={editRecord?.secondaryContactPerson}
                placeholder="Secondary name"
              />
            </div>
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">S. Contact Number</label>
              <input
                name="secondaryContactNumber"
                type="text"
                className="form-input"
                defaultValue={editRecord?.secondaryContactNumber}
                placeholder="Secondary number"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Status</label>
              <select
                name="approvalStatus"
                className="form-input"
                defaultValue={editRecord?.approvalStatus || 'Pending'}
              >
                <option value="Approved">Approved</option>
                <option value="Pending">Pending</option>
                <option value="Rejected">Rejected</option>
              </select>
            </div>
            <div>
              <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
                Password {editRecord && <span className="normal-case font-normal text-slate-400 ml-1">(Optional)</span>}
              </label>
              <input
                name="password"
                type="password"
                className="form-input"
                placeholder={editRecord ? '••••••••' : 'Set password'}
                required={!editRecord}
              />
            </div>
          </div>

          <div>
            <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Address List (Comma Sep)</label>
            <input
              name="addressList"
              type="text"
              className="form-input"
              defaultValue={editRecord?.addressList?.join(', ')}
              placeholder="e.g. Karachi, Lahore"
            />
          </div>

          <div>
            <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">Rejection Comment</label>
            <textarea
              name="rejectionComment"
              className="form-input h-16 resize-none py-2"
              defaultValue={editRecord?.rejectionComment}
              placeholder="Reason for rejection (if applicable)..."
            ></textarea>
          </div>

          <div className="flex justify-end gap-3 pt-6 border-t border-gray-100 mt-4">
            <button type="button" onClick={onClose} className="px-6 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-50 rounded-lg transition-colors border border-slate-200">
              Cancel
            </button>
            <button type="submit" className="px-8 py-2 text-sm font-semibold text-white bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors shadow-lg shadow-blue-500/20">
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
  const [loading, setLoading] = useState(false);
  const [totalCount, setTotalCount] = useState(0);
  const [currentPage, setCurrentPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');
  const [columnConfig, setColumnConfig] = useState<{id: string; visible: boolean}[]>([]);
  const itemsPerPage = 100;
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingRecord, setEditingRecord] = useState<UserRecord | null>(null);
  const [isImportModalOpen, setIsImportModalOpen] = useState(false);
  
  // Sort and Filter State
  const [activeSort, setActiveSort] = useState<{ columnId: string; direction: 'asc' | 'desc' } | null>(null);
  const [activeFilters, setActiveFilters] = useState<Record<string, any>>({});

  // API configuration
  const getBaseUrl = useCallback(() => process.env.NEXT_PUBLIC_BACKENDBASEURL || 'https://otobix-app-backend-development.onrender.com/api/', []);
  const getAddUrl = useCallback(() => `${getBaseUrl()}${process.env.NEXT_PUBLIC_USERSADD || 'user/register'}`, [getBaseUrl]);
  const getUpdateUrl = useCallback(() => `${getBaseUrl()}${process.env.NEXT_PUBLIC_USERSUPDATE || 'user/update-profile'}`, [getBaseUrl]);
  const getDeleteUrl = useCallback(() => `${getBaseUrl()}${process.env.NEXT_PUBLIC_USERSDELETE || 'user/delete'}`, [getBaseUrl]);
  const AUTH_TOKEN = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MDBhYzc2NTA4OGQxYTA2ODc3MDU0NCIsInVzZXJOYW1lIjoiY3VzdG9tZXIiLCJ1c2VyVHlwZSI6IkN1c3RvbWVyIiwiaWF0IjoxNzY0MzMxNjMxLCJleHAiOjIwNzk2OTE2MzF9.oXw1J4ca1XoIAg-vCO2y0QqZIq0VWHdYBrl2y9iIv4Q';

  // Fetch Data
  const fetchUsers = useCallback(async (page = 1, limit = 100, search = '') => {
    setLoading(true);
    const listUrl = `${getBaseUrl()}${process.env.NEXT_PUBLIC_USERSLIST || 'user/all-users-list'}`;
    console.log('[Users] Fetching users from:', listUrl);
    try {
      const url = new URL(listUrl);
      url.searchParams.append('pageNumber', page.toString());
      url.searchParams.append('limit', limit.toString());
      if (search) url.searchParams.append('search', search);

      const res = await fetch(url.toString(), {
        headers: {
          'Authorization': AUTH_TOKEN
        },
        cache: 'no-store'
      });
      if (res.ok) {
        const data = await res.json();
        console.log('[Users] API response:', data);
        
        // Handle various response types: { data: [] }, { users: [] }, { users: { data: [] } }, or [].
        let actualData = data.data || data.users || (Array.isArray(data) ? data : []);
        if (actualData && !Array.isArray(actualData) && actualData.data) {
          actualData = actualData.data;
        }

        // Handle total count
        const total = data.totalCount || data.total || (Array.isArray(actualData) ? actualData.length : 0);
        
        console.log('[Users] Extracted users count:', Array.isArray(actualData) ? actualData.length : 0);
        setUsers(Array.isArray(actualData) ? actualData : []);
        setTotalCount(total);
      } else {
        console.error('[Users] Fetch failed with status:', res.status, res.statusText);
      }
    } catch (error) {
      console.error('[Users] Fetch error:', error);
    } finally {
      setLoading(false);
    }
  }, [getBaseUrl, AUTH_TOKEN]);

  useEffect(() => {
    fetchUsers(currentPage, itemsPerPage, searchTerm);
  }, [currentPage, searchTerm, fetchUsers]);

  useEffect(() => {
    const loadConfig = async () => {
      let savedConfigs = null;

      try {
        const res = await fetch('/api/settings');
        if (res.ok) {
          const settings = await res.json();
          const targetSetting = settings.find((s: any) => s.key === 'users_columns_config');
          if (targetSetting && targetSetting.value) {
            savedConfigs = typeof targetSetting.value === 'string' 
              ? JSON.parse(targetSetting.value) 
              : targetSetting.value;
            console.log('[Users] Loaded column config from MongoDB');
          }
        }
      } catch (err) {
        console.warn('[Users] MongoDB config load failed:', err);
      }

      if (!savedConfigs) {
        const saved = localStorage.getItem('users_columns_config');
        if (saved) {
          try {
            savedConfigs = JSON.parse(saved);
            console.log('[Users] Loaded column config from localStorage');
          } catch (err) {
            console.error('[Users] Error parsing local storage:', err);
          }
        }
      }

      if (savedConfigs) {
        setColumnConfig(savedConfigs);
      }
    };

    loadConfig();
  }, []);

  // Set Header
  useEffect(() => {
    setTitle('App Users');
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
    setActionsContent(null);
  }, [setTitle, setSearchContent, setActionsContent, searchTerm]);

  // Handlers
  const handleSave = useCallback(async (data: any) => {
    try {
      const isEdit = !!editingRecord;
      const url = isEdit ? getUpdateUrl() : getAddUrl();
      const method = 'POST'; // Backend typically uses POST for both add and update profiles

      // Include ID if editing
      if (isEdit) {
          data.userId = editingRecord._id; // Backend might expect userId for update
      }

      const res = await fetch(url, {
        method,
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': AUTH_TOKEN
        },
        body: JSON.stringify(data),
      });

      if (res.ok) {
        fetchUsers(currentPage, itemsPerPage, searchTerm);
        setIsModalOpen(false);
        setEditingRecord(null);
      } else {
        const err = await res.json();
        alert('Error: ' + (err.error || err.message || 'Failed to save'));
      }
    } catch (error) {
      alert('Failed to save user');
    }
  }, [editingRecord, getUpdateUrl, getAddUrl, fetchUsers, currentPage, itemsPerPage, searchTerm, AUTH_TOKEN]);

  const handleDelete = useCallback(async (id: string) => {
    if (!confirm('Are you sure you want to delete this user?')) return;
    try {
      const res = await fetch(getDeleteUrl(), { 
        method: 'POST', // Backend often uses POST for delete too
        headers: {
            'Content-Type': 'application/json',
            'Authorization': AUTH_TOKEN
        },
        body: JSON.stringify({ userId: id })
      });
      if (res.ok) {
          fetchUsers(currentPage, itemsPerPage, searchTerm);
      } else {
          const err = await res.json();
          alert('Delete failed: ' + (err.error || err.message || 'Unknown error'));
      }
    } catch (error) {
      alert('Failed to delete user');
    }
  }, [getDeleteUrl, fetchUsers, currentPage, itemsPerPage, searchTerm, AUTH_TOKEN]);

  // Columns Map
  const columnDefinitions: Record<string, any> = useMemo(() => ({
    userName: {
      id: 'userName',
      header: 'Name',
      type: 'text',
      sortable: true,
      filterable: true,
      render: (row: UserRecord) => (
        <div className="flex items-center gap-2">
          {row.image ? (
            <img src={row.image} alt={row.userName} className="w-8 h-8 rounded-full object-cover" />
          ) : (
            <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 text-[10px] font-bold uppercase">
              {row.userName?.slice(0, 2)}
            </div>
          )}
          <span className="font-medium text-slate-900">{row.userName}</span>
        </div>
      ),
    },
    email: {
      id: 'email',
      header: 'Email',
      accessor: 'email',
      type: 'text',
      sortable: true,
      filterable: true,
      className: 'text-xs',
    },
    phoneNumber: {
      id: 'phoneNumber',
      header: 'Phone',
      accessor: 'phoneNumber',
      type: 'text',
      sortable: true,
      filterable: true,
      className: 'text-[10px] font-mono',
    },
    userRole: {
      id: 'userRole',
      header: 'Role',
      type: 'enum',
      sortable: true,
      filterable: true,
      options: [
        { label: 'Admin', value: 'Admin' },
        { label: 'Staff', value: 'Staff' },
        { label: 'Dealer', value: 'Dealer' },
        { label: 'User', value: 'User' },
      ],
      render: (row: UserRecord) => (
        <span
          className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wide 
          ${row.userRole === 'Admin' ? 'bg-purple-100 text-purple-700' : 'bg-gray-100 text-gray-600'}`}
        >
          {row.userRole}
        </span>
      ),
    },
    approvalStatus: {
      id: 'approvalStatus',
      header: 'Status',
      type: 'enum',
      sortable: true,
      filterable: true,
      options: [
        { label: 'Approved', value: 'Approved' },
        { label: 'Pending', value: 'Pending' },
        { label: 'Rejected', value: 'Rejected' },
      ],
      render: (row: UserRecord) => {
        let colors = 'bg-gray-100 text-gray-600';
        if (row.approvalStatus === 'Approved') colors = 'bg-green-100 text-green-700';
        if (row.approvalStatus === 'Rejected') colors = 'bg-red-100 text-red-700';
        if (row.approvalStatus === 'Pending') colors = 'bg-orange-100 text-orange-700';
        return (
          <span
            className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wide ${colors}`}
          >
            {row.approvalStatus}
          </span>
        );
      },
    },
    dealershipName: {
      id: 'dealershipName',
      header: 'Dealership',
      accessor: 'dealershipName',
      type: 'text',
      sortable: true,
      filterable: true,
      className: 'text-xs font-medium text-slate-800',
    },
    location: {
      id: 'location',
      header: 'Location',
      accessor: 'location',
      type: 'text',
      sortable: true,
      filterable: true,
      className: 'text-xs',
    },
    isStaff: {
      id: 'isStaff',
      header: 'Is Staff',
      type: 'boolean',
      sortable: true,
      filterable: true,
      render: (row: UserRecord) => row.isStaff ? 'Yes' : 'No',
      className: 'text-xs',
    },
    entityType: {
      id: 'entityType',
      header: 'Entity Type',
      accessor: 'entityType',
      type: 'text',
      sortable: true,
      filterable: true,
      className: 'text-xs',
    },
    createdAt: {
      id: 'createdAt',
      header: 'Created At',
      type: 'date',
      sortable: true,
      filterable: true,
      render: (row: UserRecord) => row.createdAt ? new Date(row.createdAt).toLocaleDateString() : '-',
      className: 'text-xs',
    },
  }), []);

  const columns = useMemo(() => {
    const actionsColumn = {
      header: 'Actions',
      align: 'right' as const,
      render: (row: UserRecord) => (
        <div className="flex items-center justify-end gap-1">
          <button
            onClick={() => {
              setEditingRecord(row);
              setIsModalOpen(true);
            }}
            className="p-1.5 text-slate-500 hover:text-blue-500 hover:bg-blue-50 rounded transition-colors"
          >
            <Edit2 className="w-3.5 h-3.5" />
          </button>
        </div>
      ),
    };

    console.log('[Users] Current columnConfig:', columnConfig);

    if (columnConfig.length === 0) {
      const defaultCols = [
        columnDefinitions.userName,
        columnDefinitions.email,
        columnDefinitions.phoneNumber,
        columnDefinitions.userRole,
        columnDefinitions.approvalStatus,
        columnDefinitions.dealershipName,
        columnDefinitions.location,
        actionsColumn,
      ];
      console.log('[Users] Using default columns:', defaultCols.length);
      return defaultCols;
    }

    const dynamicColumns = columnConfig
      .filter((col) => col.visible)
      .map((col) => {
        const def = columnDefinitions[col.id];
        if (!def) console.warn('[Users] Column definition not found for ID:', col.id);
        return def;
      })
      .filter(Boolean);

    console.log('[Users] Using dynamic columns:', dynamicColumns.length + 1);
    return [...dynamicColumns, actionsColumn];
  }, [columnConfig, columnDefinitions]);

  // Client-side Sort and Filter Logic
  const processedUsers = useMemo(() => {
    let result = [...users];

    // Apply Active Filters
    Object.entries(activeFilters).forEach(([key, filterValue]) => {
      // Robust empty check
      if (filterValue === undefined || filterValue === null) return;
      if (Array.isArray(filterValue) && filterValue.length === 0) return;
      if (typeof filterValue === 'string' && filterValue.trim() === '') return;

      const colDef = columnDefinitions[key];
      const type = colDef?.type || 'text';

      result = result.filter(user => {
        const val = (user as any)[key];
        
        switch (type) {
          case 'text':
            return String(val || '').toLowerCase().includes(String(filterValue).toLowerCase());
          case 'boolean':
            const filterBool = filterValue === true || filterValue === 'true';
            // Match if strictly equal, or if record is falsy and filter is false
            const actualBool = !!val;
            return actualBool === filterBool;
          case 'enum':
            if (Array.isArray(filterValue)) {
              return filterValue.length === 0 || filterValue.includes(val);
            }
            return val === filterValue;
          case 'number':
            const { min, max } = filterValue;
            const numVal = Number(val);
            if (isNaN(numVal)) return false;
            if (min !== undefined && min !== '' && numVal < Number(min)) return false;
            if (max !== undefined && max !== '' && numVal > Number(max)) return false;
            return true;
          case 'date':
            if (!filterValue.from) return true;
            const recordDate = val ? new Date(val) : null;
            if (!recordDate || isNaN(recordDate.getTime())) return false;
            
            const fromDate = new Date(filterValue.from);
            fromDate.setHours(0, 0, 0, 0);
            if (recordDate < fromDate) return false;
            
            if (filterValue.to) {
              const toDate = new Date(filterValue.to);
              toDate.setHours(23, 59, 59, 999);
              if (recordDate > toDate) return false;
            }
            return true;
          default:
            return true;
        }
      });
    });

    // Apply Sort
    if (activeSort) {
      const { columnId, direction } = activeSort;
      result.sort((a, b) => {
        const valA = (a as any)[columnId];
        const valB = (b as any)[columnId];
        
        // Handle undefined/null values for sorting
        if (valA === valB) return 0;
        if (valA === undefined || valA === null) return direction === 'asc' ? 1 : -1;
        if (valB === undefined || valB === null) return direction === 'asc' ? -1 : 1;

        if (valA < valB) return direction === 'asc' ? -1 : 1;
        if (valA > valB) return direction === 'asc' ? 1 : -1;
        return 0;
      });
    }

    return result;
  }, [users, activeFilters, activeSort, columnDefinitions]);

  return (
    <div className="h-full flex flex-col bg-white overflow-hidden">
      <div className="flex-1 overflow-hidden">
        <Table
          columns={columns}
          data={processedUsers}
          keyField="_id"
          isLoading={loading}
          onRowClick={(row) => {
            setEditingRecord(row);
            setIsModalOpen(true);
          }}
          activeFilters={activeFilters}
          activeSort={activeSort}
          onSort={(id, dir) => setActiveSort(dir ? { columnId: id, direction: dir } : null)}
          onFilter={(id, val) => setActiveFilters(prev => ({ ...prev, [id]: val }))}
          pagination={{
            currentPage: currentPage,
            totalPages: Math.ceil(totalCount / itemsPerPage),
            totalItems: totalCount,
            startIndex: (currentPage - 1) * itemsPerPage,
            endIndex: Math.min(currentPage * itemsPerPage, totalCount),
            onNext: () => setCurrentPage(p => p + 1),
            onPrev: () => setCurrentPage(p => p - 1),
            onSetPage: (p) => setCurrentPage(p),
            canNext: currentPage < Math.ceil(totalCount / itemsPerPage),
            canPrev: currentPage > 1,
          }}
        />
      </div>

      <UserModal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setEditingRecord(null);
        }}
        onSubmit={handleSave}
        editRecord={editingRecord}
      />

      <GlobalImportModal
        isOpen={isImportModalOpen}
        onClose={() => setIsImportModalOpen(false)}
        endpoint="/api/users/import"
        title="Import Users"
        onSuccess={() => {
          fetchUsers(currentPage, itemsPerPage, searchTerm);
          setTimeout(() => setIsImportModalOpen(false), 1500);
        }}
      />
    </div>
  );
}
