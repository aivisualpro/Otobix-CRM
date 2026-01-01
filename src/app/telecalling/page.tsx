'use client';

import { useState, useEffect, useMemo, FormEvent, useRef } from 'react';
import { useSession } from 'next-auth/react';
import {
  Search,
  Plus,
  Filter,
  Download,
  Edit2,
  Trash2,
  Phone,
  Calendar,
  Clock,
  X,
  User,
  AlertCircle,
  Car,
} from 'lucide-react';
import { useHeader } from '@/context/HeaderContext';
import Table from '@/components/Table';
import GlobalImportModal from '@/components/GlobalImportModal';

// --- Types ---

interface TelecallingRecord {
  _id?: string;
  appointmentId?: string;
  
  // REQUIRED business fields
  carRegistrationNumber: string;
  yearOfRegistration: string;
  ownerName: string;
  ownershipSerialNumber: number;
  make: string;
  model: string;
  variant: string;

  // Optional/Default fields
  timeStamp?: string; // Date
  emailAddress?: string;
  appointmentSource?: string;
  vehicleStatus?: string;
  zipCode?: string;
  customerContactNumber?: string;
  city?: string;
  yearOfManufacture?: string;
  allocatedTo?: string;
  inspectionStatus?: string;
  approvalStatus?: string;
  priority?: string;
  ncdUcdName?: string;
  repName?: string;
  repContact?: string;
  bankSource?: string;
  referenceName?: string;
  remarks?: string;
  createdBy?: string;
  
  odometerReadingInKms?: number;
  additionalNotes?: string;
  carImages?: string[];
  inspectionDateTime?: string; // Date
  inspectionAddress?: string;
  inspectionEngineerNumber?: string;
  addedBy?: 'Customer' | 'Telecaller';

  createdAt?: string;
  updatedAt?: string;
}

interface UserOption {
  _id: string;
  userName: string;
  email: string;
  phoneNumber?: string;
}

interface DropdownOption {
  _id: string;
  description: string;
  type: string;
  icon?: string;
  color?: string;
  isActive: boolean;
}

interface TabItem {
  label: string;
  count: number;
}

// --- Components ---

const StatusBadge = ({
  status,
  dropdownOptions = [],
}: {
  status: string;
  dropdownOptions?: DropdownOption[];
}) => {
  // Find matching dropdown option for dynamic color
  const matchedOption = dropdownOptions.find(
    (d) => d.description.toLowerCase() === status.toLowerCase()
  );

  // If we have a color from dropdown, use it
  if (matchedOption?.color) {
    // Convert hex to rgba for lighter background
    const hexToRgb = (hex: string) => {
      const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
      return result
        ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16),
          }
        : null;
    };
    const rgb = hexToRgb(matchedOption.color);
    const bgColor = rgb ? `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.15)` : matchedOption.color;

    return (
      <span
        className="px-2 py-0.5 text-[10px] font-medium uppercase tracking-wide rounded"
        style={{ backgroundColor: bgColor, color: matchedOption.color }}
      >
        {status}
      </span>
    );
  }

  // Fallback to static colors if no dropdown match
  let colors = 'bg-gray-100 text-gray-700';
  if (status === 'Scheduled') colors = 'bg-blue-100 text-blue-700';
  if (status === 'Pending') colors = 'bg-yellow-100 text-yellow-700';
  if (status === 'Completed') colors = 'bg-emerald-100 text-emerald-700';
  if (status === 'Cancelled') colors = 'bg-red-100 text-red-700';

  return (
    <span
      className={`px-2 py-0.5 text-[10px] font-medium uppercase tracking-wide rounded ${colors}`}
    >
      {status}
    </span>
  );
};

const PriorityBadge = ({ priority }: { priority: string }) => {
  let colors = 'bg-gray-100 text-gray-700';
  if (priority === 'High') colors = 'bg-red-50 text-red-600 border-red-100';
  if (priority === 'Medium') colors = 'bg-orange-50 text-orange-600 border-orange-100';
  if (priority === 'Low') colors = 'bg-blue-50 text-blue-600 border-blue-100';

  return (
    <span className={`px-2 py-0.5 text-[10px] font-medium border rounded ${colors}`}>
      {priority}
    </span>
  );
};

// Searchable User Select Component
interface SearchableUserSelectProps {
  name: string;
  users: UserOption[];
  defaultValue?: string;
  placeholder?: string;
  onSelect?: (user: UserOption | null) => void;
}

const SearchableUserSelect = ({
  name,
  users,
  defaultValue = '',
  placeholder = 'Search users...',
  onSelect,
}: SearchableUserSelectProps) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedValue, setSelectedValue] = useState(defaultValue);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Find selected user display name
  const selectedUser = users.find((u) => u.userName === selectedValue || u.email === selectedValue);
  const displayValue = selectedUser?.userName || selectedValue || '';

  const filteredUsers = users.filter(
    (u) =>
      u.userName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      u.email.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Close on click outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div className="relative" ref={dropdownRef}>
      <input type="hidden" name={name} value={selectedValue} />
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className="form-input w-full text-left flex items-center justify-between"
      >
        <span className={displayValue ? 'text-slate-900' : 'text-slate-400'}>
          {displayValue || 'Select User'}
        </span>
        <svg
          className="w-4 h-4 text-slate-400"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </button>

      {isOpen && (
        <div className="absolute z-50 mt-1 w-full bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-hidden">
          <div className="p-2 border-b border-gray-100">
            <input
              type="text"
              placeholder={placeholder}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full px-3 py-1.5 text-sm border border-gray-200 rounded focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
              autoFocus
            />
          </div>
          <div className="max-h-44 overflow-y-auto">
            <button
              type="button"
              onClick={() => {
                setSelectedValue('');
                setIsOpen(false);
                setSearchTerm('');
                if (onSelect) onSelect(null);
              }}
              className="w-full px-3 py-2 text-left text-sm text-slate-500 hover:bg-gray-50"
            >
              -- Clear Selection --
            </button>
            {filteredUsers.map((u) => (
              <button
                key={u._id}
                type="button"
                onClick={() => {
                  setSelectedValue(u.userName);
                  setIsOpen(false);
                  setSearchTerm('');
                  if (onSelect) onSelect(u);
                }}
                className={`w-full px-3 py-2 text-left text-sm hover:bg-blue-50
                  ${selectedValue === u.userName ? 'bg-blue-50 text-blue-700 font-medium' : 'text-slate-700'}`}
              >
                {u.userName}
              </button>
            ))}
            {filteredUsers.length === 0 && (
              <div className="px-3 py-4 text-center text-sm text-slate-400">No users found</div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

// Searchable Dropdown Select with Color/Icon support (for references like Appointment Source)
interface SearchableDropdownSelectProps {
  name: string;
  options: DropdownOption[];
  defaultValue?: string;
  placeholder?: string;
}

const SearchableDropdownSelect = ({
  name,
  options,
  defaultValue = '',
  placeholder = 'Search...',
}: SearchableDropdownSelectProps) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedValue, setSelectedValue] = useState(defaultValue);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const selectedOption = options.find((o) => o.description === selectedValue);
  const filteredOptions = options.filter((o) =>
    o.description.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const showAddNew =
    searchTerm && !options.some((o) => o.description.toLowerCase() === searchTerm.toLowerCase());

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node))
        setIsOpen(false);
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div className="relative" ref={dropdownRef}>
      <input type="hidden" name={name} value={selectedValue} />
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className="form-input w-full text-left flex items-center gap-2"
      >
        {selectedOption?.color && (
          <div className="w-4 h-4 rounded" style={{ backgroundColor: selectedOption.color }} />
        )}
        {selectedOption?.icon && (
          <img src={selectedOption.icon} alt="" className="w-4 h-4 object-contain" />
        )}
        <span className={selectedValue ? 'text-slate-900 flex-1' : 'text-slate-400 flex-1'}>
          {selectedValue || 'Select...'}
        </span>
        <svg
          className="w-4 h-4 text-slate-400"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </button>

      {isOpen && (
        <div className="absolute z-50 mt-1 w-full bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-hidden">
          <div className="p-2 border-b border-gray-100">
            <input
              type="text"
              placeholder={placeholder}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full px-3 py-1.5 text-sm border border-gray-200 rounded focus:outline-none focus:ring-2 focus:ring-blue-500/20"
              autoFocus
            />
          </div>
          <div className="max-h-44 overflow-y-auto">
            <button
              type="button"
              onClick={() => {
                setSelectedValue('');
                setIsOpen(false);
                setSearchTerm('');
              }}
              className="w-full px-3 py-2 text-left text-sm text-slate-500 hover:bg-gray-50"
            >
              -- Clear --
            </button>
            {showAddNew && (
              <button
                type="button"
                onClick={() => {
                  setSelectedValue(searchTerm);
                  setIsOpen(false);
                  setSearchTerm('');
                }}
                className="w-full px-3 py-2 text-left text-sm text-blue-600 hover:bg-blue-50 flex items-center gap-2"
              >
                <Plus className="w-4 h-4" /> Add &quot;{searchTerm}&quot;
              </button>
            )}
            {filteredOptions.map((opt) => (
              <button
                key={opt._id}
                type="button"
                onClick={() => {
                  setSelectedValue(opt.description);
                  setIsOpen(false);
                  setSearchTerm('');
                }}
                className={`w-full px-3 py-2 text-left text-sm hover:bg-blue-50 flex items-center gap-2 ${selectedValue === opt.description ? 'bg-blue-50 text-blue-700' : 'text-slate-700'}`}
              >
                {opt.color && (
                  <div className="w-4 h-4 rounded" style={{ backgroundColor: opt.color }} />
                )}
                {opt.icon && <img src={opt.icon} alt="" className="w-4 h-4 object-contain" />}
                <span>{opt.description}</span>
              </button>
            ))}
            {filteredOptions.length === 0 && !showAddNew && (
              <div className="px-3 py-4 text-center text-sm text-slate-400">No options found</div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

interface CallModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: Partial<TelecallingRecord>) => void;
  editRecord: TelecallingRecord | null;
  title?: string;
  users?: UserOption[];
  appointmentSources?: DropdownOption[];
  inspectionStatuses?: DropdownOption[];
}

const CallModal = ({
  isOpen,
  onClose,
  onSubmit,
  editRecord,
  title,
  users = [],
  appointmentSources = [],
  inspectionStatuses = [],
}: CallModalProps) => {
  const [engineerNumber, setEngineerNumber] = useState(editRecord?.inspectionEngineerNumber || '');

  useEffect(() => {
    setEngineerNumber(editRecord?.inspectionEngineerNumber || '');
  }, [editRecord]);

  if (!isOpen) return null;

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    
    // Construct the object matching TelecallingRecord
    const callData: Partial<TelecallingRecord> = {
      appointmentId: (editRecord?.appointmentId || formData.get('appointmentId')) as string,
      
      // Required Fields
      carRegistrationNumber: formData.get('carRegistrationNumber') as string,
      yearOfRegistration: formData.get('yearOfRegistration') as string,
      ownerName: formData.get('ownerName') as string,
      ownershipSerialNumber: parseInt(formData.get('ownershipSerialNumber') as string) || 0,
      make: formData.get('make') as string,
      model: formData.get('model') as string,
      variant: formData.get('variant') as string,

      // Other Fields
      priority: formData.get('priority') as string,
      allocatedTo: formData.get('allocatedTo') as string,
      appointmentSource: formData.get('appointmentSource') as string,
      inspectionStatus: (formData.get('inspectionStatus') as string) || 'Pending',
      customerContactNumber: formData.get('customerContactNumber') as string,
      emailAddress: formData.get('emailAddress') as string,
      city: formData.get('city') as string,
      zipCode: formData.get('zipCode') as string,
      inspectionAddress: formData.get('inspectionAddress') as string,
      yearOfManufacture: formData.get('yearOfManufacture') as string,
      odometerReadingInKms: parseFloat(formData.get('odometerReadingInKms') as string) || 0,
      vehicleStatus: formData.get('vehicleStatus') as string,
      inspectionDateTime: formData.get('inspectionDateTime') as string,
      ncdUcdName: formData.get('ncdUcdName') as string,
      repName: formData.get('repName') as string,
      repContact: formData.get('repContact') as string,
      bankSource: formData.get('bankSource') as string,
      referenceName: formData.get('referenceName') as string,
      inspectionEngineerNumber: formData.get('inspectionEngineerNumber') as string,
      addedBy: (formData.get('addedBy') as any) || 'Telecaller',
      remarks: formData.get('remarks') as string,
      additionalNotes: formData.get('additionalNotes') as string,
    };
    onSubmit(callData);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
      <div className="bg-white shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto border border-gray-100 rounded-xl">
        <div className="sticky top-0 bg-white/95 backdrop-blur-sm px-6 py-4 border-b border-gray-100 flex justify-between items-center z-10">
          <div>
            <h2 className="text-xl font-bold text-slate-900">
              {title || (editRecord ? 'Edit Record' : 'Add Lead Call Record')}
            </h2>
            <p className="text-xs text-slate-500 mt-0.5">
              {editRecord
                ? 'Update the record details'
                : 'Enter details for the new appointment call'}
            </p>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-gray-100 transition-colors rounded-lg">
            <X className="w-5 h-5 text-slate-500" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Appointment Details */}
          <div className="md:col-span-3">
            <h3 className="text-xs font-bold text-blue-600 uppercase tracking-wider mb-3 flex items-center gap-2">
              <Calendar className="w-4 h-4" /> Appointment Details
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="relative">
                <label className="text-[10px] font-bold text-slate-400 absolute -top-2 left-2 bg-white px-1">
                  Appt ID
                </label>
                <input
                  name="appointmentId"
                  type="text"
                  readOnly
                  className="form-input bg-gray-50 text-slate-500 cursor-not-allowed font-mono italic"
                  defaultValue={editRecord?.appointmentId || 'Auto-generated'}
                />
              </div>
              <select
                name="priority"
                className="form-input"
                defaultValue={editRecord?.priority || 'Medium'}
              >
                <option value="">Select Priority</option>
                <option value="High">High</option>
                <option value="Medium">Medium</option>
                <option value="Low">Low</option>
              </select>
              <SearchableUserSelect
                name="allocatedTo"
                users={users}
                defaultValue={editRecord?.allocatedTo || ''}
                placeholder="Search users..."
                onSelect={(user) => {
                  if (user && user.phoneNumber) {
                    setEngineerNumber(user.phoneNumber);
                  }
                }}
              />
              <SearchableDropdownSelect
                name="appointmentSource"
                options={appointmentSources}
                defaultValue={editRecord?.appointmentSource || ''}
                placeholder="Search sources..."
              />
              <SearchableDropdownSelect
                name="inspectionStatus"
                options={inspectionStatuses}
                defaultValue={editRecord?.inspectionStatus || 'Pending'}
                placeholder="Search status..."
              />
            </div>
          </div>

          <div className="border-t border-gray-100 md:col-span-3 my-2"></div>

          {/* Customer Info */}
          <div className="md:col-span-3">
            <h3 className="text-xs font-bold text-blue-600 uppercase tracking-wider mb-3 flex items-center gap-2">
              <User className="w-4 h-4" /> Customer Information
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <input
                name="ownerName"
                type="text"
                placeholder="Owner Name *"
                required
                className="form-input"
                defaultValue={editRecord?.ownerName || ''}
              />
              <input
                name="customerContactNumber"
                type="tel"
                placeholder="Contact Number"
                className="form-input"
                defaultValue={editRecord?.customerContactNumber || ''}
              />
              <input
                name="emailAddress"
                type="email"
                placeholder="Email Address"
                className="form-input"
                defaultValue={editRecord?.emailAddress || ''}
              />
              <input
                name="city"
                type="text"
                placeholder="City"
                className="form-input"
                defaultValue={editRecord?.city || ''}
              />
              <input
                name="zipCode"
                type="text"
                placeholder="Zip Code"
                className="form-input"
                defaultValue={editRecord?.zipCode || ''}
              />
              <div className="md:col-span-3">
                <input
                  name="inspectionAddress"
                  type="text"
                  placeholder="Address for Inspection"
                  className="form-input w-full"
                  defaultValue={editRecord?.inspectionAddress || ''}
                />
              </div>
            </div>
          </div>

          <div className="border-t border-gray-100 md:col-span-3 my-2"></div>

          {/* Vehicle Details */}
          <div className="md:col-span-3">
            <h3 className="text-xs font-bold text-blue-600 uppercase tracking-wider mb-3 flex items-center gap-2">
              <Car className="w-4 h-4" /> Vehicle Details
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <input
                name="carRegistrationNumber"
                type="text"
                placeholder="Reg. Number *"
                required
                className="form-input"
                defaultValue={editRecord?.carRegistrationNumber || ''}
              />
              <input
                name="yearOfRegistration"
                type="text"
                placeholder="Reg. Year *"
                required
                className="form-input"
                defaultValue={editRecord?.yearOfRegistration || ''}
              />
              <input
                name="ownershipSerialNumber"
                type="number"
                placeholder="Ownership Serial *"
                required
                className="form-input"
                defaultValue={editRecord?.ownershipSerialNumber || ''}
              />
              <input
                name="make"
                type="text"
                placeholder="Make *"
                required
                className="form-input"
                defaultValue={editRecord?.make || ''}
              />
              <input
                name="model"
                type="text"
                placeholder="Model *"
                required
                className="form-input"
                defaultValue={editRecord?.model || ''}
              />
              <input
                name="variant"
                type="text"
                placeholder="Variant *"
                required
                className="form-input"
                defaultValue={editRecord?.variant || ''}
              />
              <input
                name="yearOfManufacture"
                type="text"
                placeholder="Mfg Year"
                className="form-input"
                defaultValue={editRecord?.yearOfManufacture || ''}
              />
              <input
                name="odometerReadingInKms"
                type="number"
                placeholder="Odometer (Kms)"
                className="form-input"
                defaultValue={editRecord?.odometerReadingInKms || ''}
              />
              <input
                name="vehicleStatus"
                type="text"
                placeholder="Vehicle Status"
                className="form-input"
                defaultValue={editRecord?.vehicleStatus || ''}
              />
            </div>
          </div>

          <div className="border-t border-gray-100 md:col-span-3 my-2"></div>

          {/* Additional Info */}
          <div className="md:col-span-3">
            <h3 className="text-xs font-bold text-blue-600 uppercase tracking-wider mb-3 flex items-center gap-2">
              <AlertCircle className="w-4 h-4" /> Additional Info
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <input
                name="inspectionDateTime"
                type="datetime-local"
                placeholder="Inspection Date & Time"
                className="form-input"
                defaultValue={editRecord?.inspectionDateTime ? new Date(editRecord.inspectionDateTime).toISOString().slice(0, 16) : ''}
              />
              <input
                name="ncdUcdName"
                type="text"
                placeholder="NCD/UCD Name"
                className="form-input"
                defaultValue={editRecord?.ncdUcdName || ''}
              />
              <input
                name="repName"
                type="text"
                placeholder="Rep Name"
                className="form-input"
                defaultValue={editRecord?.repName || ''}
              />
              <input
                name="repContact"
                type="text"
                placeholder="Rep Contact"
                className="form-input"
                defaultValue={editRecord?.repContact || ''}
              />
              <input
                name="bankSource"
                type="text"
                placeholder="Bank Source"
                className="form-input"
                defaultValue={editRecord?.bankSource || ''}
              />
              <input
                name="referenceName"
                type="text"
                placeholder="Reference Name"
                className="form-input"
                defaultValue={editRecord?.referenceName || ''}
              />
              <input
                name="inspectionEngineerNumber"
                type="text"
                placeholder="Engineer Number"
                className="form-input"
                value={engineerNumber}
                onChange={(e) => setEngineerNumber(e.target.value)}
              />
              <select
                name="addedBy"
                className="form-input"
                defaultValue={editRecord?.addedBy || 'Telecaller'}
              >
                <option value="Telecaller">Telecaller</option>
                <option value="Customer">Customer</option>
              </select>
            </div>
          </div>

          {/* Remarks */}
          <div className="md:col-span-3">
            <label className="text-xs font-semibold text-slate-500 mb-1 block">Remarks</label>
            <textarea
              name="remarks"
              className="form-input w-full h-24 resize-none mb-4"
              placeholder="Enter remarks..."
              defaultValue={editRecord?.remarks || ''}
            ></textarea>
            
            <label className="text-xs font-semibold text-slate-500 mb-1 block">Additional Notes</label>
            <textarea
              name="additionalNotes"
              className="form-input w-full h-24 resize-none"
              placeholder="Additional notes..."
              defaultValue={editRecord?.additionalNotes || ''}
            ></textarea>
          </div>

          <div className="md:col-span-3 flex justify-end gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="px-5 py-2.5 border border-gray-300 text-slate-700 font-medium hover:bg-gray-100 transition-colors text-sm rounded-lg"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-5 py-2.5 bg-blue-500 text-white font-medium hover:bg-blue-600 transition-colors text-sm rounded-lg"
            >
              {editRecord ? 'Update Record' : 'Save Record'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

// Delete Confirmation Modal
interface DeleteModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  recordName?: string;
}

const DeleteModal = ({ isOpen, onClose, onConfirm, recordName }: DeleteModalProps) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
      <div className="bg-white shadow-2xl w-full max-w-md border border-gray-100 rounded-xl p-6">
        <div className="flex items-center gap-3 mb-4">
          <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
            <Trash2 className="w-5 h-5 text-red-600" />
          </div>
          <div>
            <h2 className="text-lg font-bold text-slate-900">Delete Record</h2>
            <p className="text-xs text-slate-500">This action cannot be undone</p>
          </div>
        </div>

        <p className="text-sm text-slate-600 mb-6">
          Are you sure you want to delete the record for{' '}
          <span className="font-semibold">{recordName || 'this customer'}</span>?
        </p>

        <div className="flex justify-end gap-3">
          <button
            onClick={onClose}
            className="px-4 py-2 border border-gray-300 text-slate-700 font-medium hover:bg-gray-100 transition-colors text-sm rounded-lg"
          >
            Cancel
          </button>
          <button
            onClick={onConfirm}
            className="px-4 py-2 bg-red-500 text-white font-medium hover:bg-red-600 transition-colors text-sm rounded-lg"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
  );
};

// --- Main Component ---

export default function TelecallingPage() {
  const { data: session } = useSession();
  const currentUser = session?.user;

  const { setTitle, setSearchContent, setActionsContent } = useHeader();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isImportModalOpen, setIsImportModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [editingRecord, setEditingRecord] = useState<TelecallingRecord | null>(null);
  const [deletingRecord, setDeletingRecord] = useState<TelecallingRecord | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const [activeTab, setActiveTab] = useState('All');
  const [isFilterOpen, setIsFilterOpen] = useState(false);
  const filterRef = useRef<HTMLDivElement>(null);

  const [allLeadCalls, setAllLeadCalls] = useState<TelecallingRecord[]>([]);
  const [users, setUsers] = useState<UserOption[]>([]);
  const [appointmentSources, setAppointmentSources] = useState<DropdownOption[]>([]);
  const [inspectionStatuses, setInspectionStatuses] = useState<DropdownOption[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  // removed generatedId state
  const itemsPerPage = 20;

  // API Endpoints from environment variables
  const getBaseUrl = () => process.env.NEXT_PUBLIC_BACKENDBASEURL || 'https://otobix-app-backend-development.onrender.com/api/';
  const getListUrl = () => `${getBaseUrl()}${process.env.NEXT_PUBLIC_TELECALLINGLIST || 'inspection/telecallings/get-list-by-telecaller'}`;
  const getAddUrl = () => `${getBaseUrl()}${process.env.NEXT_PUBLIC_TELECALLINGADD || 'inspection/telecallings/add'}`;
  const getUpdateUrl = () => `${getBaseUrl()}${process.env.NEXT_PUBLIC_TELECALLINGUPDATE || 'inspection/telecallings/update'}`;
  const getDeleteUrl = () => `${getBaseUrl()}${process.env.NEXT_PUBLIC_TELECALLINGDELETE || 'inspection/telecallings/delete'}`;
  
  const AUTH_TOKEN = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MDBhYzc2NTA4OGQxYTA2ODc3MDU0NCIsInVzZXJOYW1lIjoiY3VzdG9tZXIiLCJ1c2VyVHlwZSI6IkN1c3RvbWVyIiwiaWF0IjoxNzY0MzMxNjMxLCJleHAiOjIwNzk2OTE2MzF9.oXw1J4ca1XoIAg-vCO2y0QqZIq0VWHdYBrl2y9iIv4Q';

  // Ref for debounced save timeout
  const saveTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const fetchTelecallingData = async () => {
    setLoading(true);
    
    // Clear any existing telecalling cache to free up space
    if (typeof window !== 'undefined') {
      localStorage.removeItem('otobix_telecalling_cache');
    }

    try {
      const teleRes = await fetch(getListUrl(), {
          method: 'GET',
          headers: {
            'Authorization': AUTH_TOKEN
          }
      });
      
      if (!teleRes.ok) {
        throw new Error(`Backend returned ${teleRes.status}: ${teleRes.statusText}`);
      }

      const teleData = await teleRes.json();
      const calls = Array.isArray(teleData) ? teleData : (teleData.data && Array.isArray(teleData.data) ? teleData.data : []);
      setAllLeadCalls(calls);
    } catch (error) {
      console.error('Failed to fetch telecalling data', error);
      setAllLeadCalls([]);
    } finally {
      setLoading(false);
    }
  };

  const fetchAuxData = async () => {
    try {
      // 1. Load from cache first for instant render
      if (typeof window !== 'undefined') {
        const cachedUsers = localStorage.getItem('otobix_users');
        const cachedSources = localStorage.getItem('otobix_appt_sources');
        const cachedStatuses = localStorage.getItem('otobix_insp_statuses');

        if (cachedUsers) setUsers(JSON.parse(cachedUsers));
        if (cachedSources) setAppointmentSources(JSON.parse(cachedSources));
        if (cachedStatuses) setInspectionStatuses(JSON.parse(cachedStatuses));
      }

      // 2. Fetch fresh data in background
      const [usersRes, apptSourcesRes, inspStatusesRes] = await Promise.all([
        fetch('/api/users'),
        fetch('/api/dropdowns?type=Appointment Source'),
        fetch('/api/dropdowns?type=Inspection Status'),
      ]);

      if (!usersRes.ok || !apptSourcesRes.ok || !inspStatusesRes.ok) {
          console.warn('One or more aux data fetches failed', {
              users: usersRes.status,
              apptSources: apptSourcesRes.status,
              inspStatuses: inspStatusesRes.status
          });
      }

      const usersData = usersRes.ok ? await usersRes.json() : [];
      const apptSourcesData = apptSourcesRes.ok ? await apptSourcesRes.json() : [];
      const inspStatusesData = inspStatusesRes.ok ? await inspStatusesRes.json() : [];

      const validUsers = Array.isArray(usersData) ? usersData : [];
      const validSources = Array.isArray(apptSourcesData) ? apptSourcesData.filter((d: DropdownOption) => d.isActive) : [];
      const validStatuses = Array.isArray(inspStatusesData) ? inspStatusesData.filter((d: DropdownOption) => d.isActive) : [];

      setUsers(validUsers);
      setAppointmentSources(validSources);
      setInspectionStatuses(validStatuses);

      // 3. Update cache
      if (typeof window !== 'undefined') {
        localStorage.setItem('otobix_users', JSON.stringify(validUsers));
        localStorage.setItem('otobix_appt_sources', JSON.stringify(validSources));
        localStorage.setItem('otobix_insp_statuses', JSON.stringify(validStatuses));
      }

    } catch (error) {
       console.error('Failed to fetch aux data', error);
    }
  };

  useEffect(() => {
    fetchTelecallingData();
    fetchAuxData();
  }, []);

  // Close filter dropdown on click outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (filterRef.current && !filterRef.current.contains(event.target as Node)) {
        setIsFilterOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleRefresh = () => {
    fetchTelecallingData();
    fetchAuxData();
  };

  // Optimistic Add - update UI immediately, save to backend after delay
  const handleAddCall = async (newCall: Partial<TelecallingRecord>) => {
    // Generate temporary ID for optimistic update
    const tempId = `temp-${Date.now()}`;
    const optimisticRecord = { ...newCall, _id: tempId } as TelecallingRecord;

    // Update UI immediately
    setAllLeadCalls((prev) => [optimisticRecord, ...prev]);
    setIsModalOpen(false);

    // Save to backend immediately
    try {
      const payload = { 
        ...newCall,
        inspectionStatus: newCall.inspectionStatus || 'Pending',
        approvalStatus: newCall.approvalStatus || 'Pending',
        priority: newCall.priority || 'Medium',
        addedBy: newCall.addedBy || 'Telecaller',
        carImages: newCall.carImages || [],
        createdBy: currentUser?.id || '',
      };
      
      delete payload._id;
      if (payload.appointmentId === 'Auto-generated') {
          delete payload.appointmentId;
      }

      const res = await fetch(getAddUrl(), {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AUTH_TOKEN
        },
        body: JSON.stringify(payload),
      });

      if (res.ok) {
        const savedRecord = await res.json();
        // Replace temp record with actual saved record
        // Handle if response is wrapped
        const actualRecord = savedRecord.data || savedRecord;
        setAllLeadCalls((prev) => prev.map((r) => (r._id === tempId ? actualRecord : r)));
      } else {
        // Revert on failure
        setAllLeadCalls((prev) => prev.filter((r) => r._id !== tempId));
        const err = await res.json();
        alert('Failed to save to backend: ' + (err.error || err.message || 'Unknown error'));
      }
    } catch (error) {
      setAllLeadCalls((prev) => prev.filter((r) => r._id !== tempId));
      alert('Failed to save call: ' + (error as Error).message);
    }
  };

  // Optimistic Edit
  const handleEditCall = async (updatedData: Partial<TelecallingRecord>) => {
     if (!editingRecord) return;
     const recordId = editingRecord._id;
     const oldRecord = { ...editingRecord };
     const newRecord = { ...editingRecord, ...updatedData };

     // Optimistic update
     setAllLeadCalls(prev => prev.map(r => r._id === recordId ? newRecord : r));
     setIsModalOpen(false);

     try {
       const payload = {
         ...updatedData,
         telecallingId: recordId, // Required field
         changedBy: currentUser?.id || '',
         source: currentUser?.role || '',
       };
       delete (payload as any)._id;
       delete (payload as any).id;

       const res = await fetch(getUpdateUrl(), {
         method: 'PUT',
         headers: {
           'Content-Type': 'application/json',
           'Authorization': AUTH_TOKEN
         },
         body: JSON.stringify(payload),
       });

       if (!res.ok) {
         setAllLeadCalls(prev => prev.map(r => r._id === recordId ? oldRecord : r));
         const err = await res.json();
         alert('Failed to update: ' + (err.error || err.message || 'Unknown error'));
       }
     } catch (error) {
       setAllLeadCalls(prev => prev.map(r => r._id === recordId ? oldRecord : r));
       alert('Update error: ' + (error as Error).message);
     }
  };

  // Optimistic Delete
  const handleDeleteCall = async () => {
    if (!deletingRecord) return;
    const recordId = deletingRecord._id;
    const oldRecord = { ...deletingRecord };

    // Optimistic delete
    setAllLeadCalls(prev => prev.filter(r => r._id !== recordId));
    setIsDeleteModalOpen(false);

    try {
      const res = await fetch(getDeleteUrl(), {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AUTH_TOKEN
        },
        body: JSON.stringify({ telecallingId: recordId }),
      });

      if (!res.ok) {
        setAllLeadCalls(prev => [oldRecord, ...prev]);
        const err = await res.json();
        alert('Failed to delete: ' + (err.error || err.message || 'Unknown error'));
      }
    } catch (error) {
      setAllLeadCalls(prev => [oldRecord, ...prev]);
      alert('Delete error: ' + (error as Error).message);
    }
  };

  const handleOpenAddModal = () => {
    setEditingRecord(null);
    setIsModalOpen(true);
  };

  const openEditModal = (record: TelecallingRecord) => {
    setEditingRecord(record);
    setIsModalOpen(true);
  };

  const openDeleteModal = (record: TelecallingRecord) => {
    setDeletingRecord(record);
    setIsDeleteModalOpen(true);
  };

  // Tab Counts - Dynamic based on data
  const tabCounts = useMemo(() => {
    const counts: Record<string, number> = { All: allLeadCalls.length };
    allLeadCalls.forEach((call) => {
      const status = call.inspectionStatus || 'Pending';
      counts[status] = (counts[status] || 0) + 1;
    });
    return counts;
  }, [allLeadCalls]);

  const tabs: TabItem[] = useMemo(() => {
    const preferredOrder = ['All', 'Scheduled', 'Pending', 'Completed', 'Cancelled'];
    const allStatuses = Object.keys(tabCounts);

    const sortedStatuses = allStatuses.sort((a, b) => {
      const indexA = preferredOrder.indexOf(a);
      const indexB = preferredOrder.indexOf(b);

      if (indexA !== -1 && indexB !== -1) return indexA - indexB;
      if (indexA !== -1) return -1;
      if (indexB !== -1) return 1;
      return a.localeCompare(b);
    });

    return sortedStatuses.map((status) => ({
      label: status,
      count: tabCounts[status],
    }));
  }, [tabCounts]);

  // Debounce search
  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedSearch(searchTerm);
      setCurrentPage(1);
    }, 150);
    return () => clearTimeout(handler);
  }, [searchTerm]);

  // Header Content
  useEffect(() => {
    setTitle('Lead Calls');
    setSearchContent(
      <div className="relative group w-full max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search..."
          className="w-full pl-9 pr-4 py-1.5 bg-gray-50 border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-xs rounded-lg"
          value={searchTerm}
          onChange={(e) => {
            setSearchTerm(e.target.value);
            setCurrentPage(1);
          }}
        />
      </div>
    );
    setActionsContent(
      <div className="flex items-center gap-2">
        <button
          onClick={() => setIsImportModalOpen(true)}
          className="flex items-center justify-center w-8 h-8 text-blue-500 hover:bg-blue-50 transition-colors border border-blue-200 rounded-lg"
          title="Import Data"
        >
          <Download className="w-4 h-4" />
        </button>

        {/* Filter Dropdown */}
        <div className="relative" ref={filterRef}>
          <button
            onClick={() => setIsFilterOpen(!isFilterOpen)}
            className={`flex items-center justify-center w-8 h-8 transition-colors border border-gray-200 rounded-lg ${isFilterOpen ? 'bg-blue-50 text-blue-600 border-blue-200' : 'text-slate-600 hover:bg-gray-100'}`}
          >
            <Filter className="w-4 h-4" />
          </button>
          {isFilterOpen && (
            <div className="absolute right-0 top-full mt-2 w-52 bg-white rounded-xl shadow-lg py-1 z-50 border border-gray-100">
              <div className="px-3 py-2 text-[10px] font-bold text-slate-400 uppercase tracking-widest border-b border-gray-50 mb-1">
                Filter by Status
              </div>
              {tabs.map((tab) => {
                const matchedOption = inspectionStatuses.find(
                  (d) => d.description.toLowerCase() === tab.label.toLowerCase()
                );
                const hexToRgb = (hex: string) => {
                  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
                  return result
                    ? {
                        r: parseInt(result[1], 16),
                        g: parseInt(result[2], 16),
                        b: parseInt(result[3], 16),
                      }
                    : null;
                };
                const rgb = matchedOption?.color ? hexToRgb(matchedOption.color) : null;
                const bgColor = rgb ? `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.15)` : undefined;
                const textColor = matchedOption?.color || undefined;

                return (
                  <button
                    key={tab.label}
                    onClick={() => {
                      setActiveTab(tab.label);
                      setCurrentPage(1);
                      setIsFilterOpen(false);
                    }}
                    className={`w-full text-left px-4 py-2 text-xs flex items-center justify-between hover:bg-slate-50 transition-colors
                      ${activeTab === tab.label ? 'font-bold' : ''}`}
                    style={
                      activeTab === tab.label && textColor
                        ? { backgroundColor: bgColor, color: textColor }
                        : undefined
                    }
                  >
                    <span
                      style={textColor && tab.label !== 'All' ? { color: textColor } : undefined}
                    >
                      {tab.label}
                    </span>
                    <span
                      className="text-[10px] px-1.5 py-0.5 rounded-full"
                      style={
                        textColor && tab.label !== 'All'
                          ? { backgroundColor: bgColor, color: textColor }
                          : {
                              backgroundColor: activeTab === tab.label ? '#3b82f6' : '#f1f5f9',
                              color: activeTab === tab.label ? 'white' : '#64748b',
                            }
                      }
                    >
                      {tab.count}
                    </span>
                  </button>
                );
              })}
            </div>
          )}
        </div>

        <button
          onClick={handleOpenAddModal}
          className="flex items-center justify-center w-8 h-8 bg-blue-500 text-white shadow-lg shadow-blue-500/20 hover:bg-blue-600 transition-colors rounded-lg"
          title="Add Call"
        >
          <Plus className="w-5 h-5" />
        </button>
      </div>
    );
  }, [
    setTitle,
    setSearchContent,
    setActionsContent,
    searchTerm,
    activeTab,
    tabs,
    isFilterOpen,
    inspectionStatuses,
  ]);

  // Filtering Logic
  const { currentCalls, pagination } = useMemo(() => {
    const filtered = allLeadCalls.filter((call) => {
      const matchesSearch =
        (call.ownerName || '').toLowerCase().includes(debouncedSearch.toLowerCase()) ||
        (call.carRegistrationNumber || '').toLowerCase().includes(debouncedSearch.toLowerCase()) ||
        (call._id || '').toLowerCase().includes(debouncedSearch.toLowerCase()) ||
        (call.make || '').toLowerCase().includes(debouncedSearch.toLowerCase());

      const matchesTab = activeTab === 'All' || call.inspectionStatus === activeTab;

      return matchesSearch && matchesTab;
    });

    const total = filtered.length;
    const start = (currentPage - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    const sliced = filtered.slice(start, end);

    return {
      currentCalls: sliced,
      pagination: {
        currentPage,
        totalItems: total,
        totalPages: Math.ceil(total / itemsPerPage),
        startIndex: start,
        endIndex: Math.min(end, total),
        onNext: () => setCurrentPage((p) => p + 1),
        onPrev: () => setCurrentPage((p) => p - 1),
        onSetPage: (p: number) => setCurrentPage(p),
        canNext: start + itemsPerPage < total,
        canPrev: currentPage > 1,
      },
    };
  }, [allLeadCalls, debouncedSearch, activeTab, currentPage, itemsPerPage]);

  // Table Columns
  const columns = [
    {
      header: 'Appt ID',
      accessor: 'appointmentId' as keyof TelecallingRecord,
      className: 'font-mono text-xs text-slate-500 whitespace-nowrap',
      width: 'auto',
    },
    {
      header: 'Reg. No',
      accessor: 'carRegistrationNumber' as keyof TelecallingRecord,
      className: 'font-bold text-slate-700 whitespace-nowrap',
      width: 'auto',
    },
    {
       header: 'Owner',
       accessor: 'ownerName' as keyof TelecallingRecord,
       className: 'font-semibold text-slate-900 whitespace-nowrap',
       width: 'auto',
    },
    {
      header: 'City',
      accessor: 'city' as keyof TelecallingRecord,
      className: 'text-slate-600 whitespace-nowrap',
      width: 'auto',
    },
    {
      header: 'Allocated To',
      render: (row: TelecallingRecord) => {
        const user = users.find(
          (u) => u.email === row.allocatedTo || u.userName === row.allocatedTo
        );
        return (
          <span className="text-slate-600 whitespace-nowrap">
            {user?.userName || row.allocatedTo || '-'}
          </span>
        );
      },
      width: 'auto',
    },
    {
      header: 'Status',
      render: (row: TelecallingRecord) => (
        <StatusBadge
          status={row.inspectionStatus || 'Pending'}
          dropdownOptions={inspectionStatuses}
        />
      ),
      width: 'auto',
    },
    {
      header: 'Inspection Date',
      render: (row: TelecallingRecord) => row.inspectionDateTime ? new Date(row.inspectionDateTime).toLocaleDateString() : '-',
      className: 'text-slate-600 whitespace-nowrap',
      width: 'auto',
    },
    {
      header: 'Priority',
      render: (row: TelecallingRecord) => <PriorityBadge priority={row.priority || 'Medium'} />,
      width: 'auto',
    },
    {
      header: 'Make',
      accessor: 'make' as keyof TelecallingRecord,
      className: 'text-slate-700 whitespace-nowrap',
      width: 'auto',
    },
    {
      header: 'Model',
      accessor: 'model' as keyof TelecallingRecord,
      className: 'text-slate-700 whitespace-nowrap',
      width: 'auto',
    },
    {
      header: 'Variant',
      accessor: 'variant' as keyof TelecallingRecord,
      className: 'text-slate-600 whitespace-nowrap',
      width: 'auto',
    },
    {
      header: 'Contact',
      accessor: 'customerContactNumber' as keyof TelecallingRecord,
      className: 'text-slate-600 font-mono text-xs whitespace-nowrap',
      width: 'auto',
    },
    {
      header: 'Source',
      render: (row: TelecallingRecord) => {
        const source = row.appointmentSource;
        if (!source) return <span className="text-slate-400 text-xs">-</span>;

        const matchedOption = appointmentSources.find(
          (d) => d.description.toLowerCase() === source.toLowerCase()
        );

        if (matchedOption?.color) {
          const hexToRgb = (hex: string) => {
            const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
            return result
              ? {
                  r: parseInt(result[1], 16),
                  g: parseInt(result[2], 16),
                  b: parseInt(result[3], 16),
                }
              : null;
          };
          const rgb = hexToRgb(matchedOption.color);
          const bgColor = rgb ? `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.15)` : matchedOption.color;

          return (
            <span
              className="px-2 py-0.5 text-[10px] font-medium uppercase tracking-wide rounded whitespace-nowrap"
              style={{ backgroundColor: bgColor, color: matchedOption.color }}
            >
              {source}
            </span>
          );
        }

        return <span className="text-slate-600 text-xs whitespace-nowrap">{source}</span>;
      },
      width: 'auto',
    },
    {
      header: 'Remarks',
      accessor: 'remarks' as keyof TelecallingRecord,
      className: 'text-slate-500 text-xs whitespace-normal min-w-[250px]',
      width: 'auto',
    },
    {
      header: 'Created By',
      render: (row: TelecallingRecord) => {
        const user = users.find(
          (u) =>
            u._id === row.createdBy ||
            u.email === row.createdBy ||
            u.userName === row.createdBy
        );
        return (
          <span className="text-slate-500 text-xs whitespace-nowrap">
            {user?.userName || row.createdBy || '-'}
          </span>
        );
      },
      width: 'auto',
    },
    {
      header: 'Created At',
      render: (row: TelecallingRecord) =>
        row.createdAt ? new Date(row.createdAt).toLocaleDateString() : '-',
      className: 'text-slate-500 text-xs whitespace-nowrap',
      width: 'auto',
    },
    {
      header: 'Actions',
      align: 'right' as const,
      render: (row: TelecallingRecord) => (
        <div className="flex items-center justify-end gap-1">
          <button
            onClick={(e) => {
              e.stopPropagation();
              openEditModal(row);
            }}
            className="text-slate-400 hover:text-blue-500 transition-colors p-1.5 hover:bg-blue-50 rounded"
            title="Edit"
          >
            <Edit2 className="w-3.5 h-3.5" />
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation();
              openDeleteModal(row);
            }}
            className="text-slate-400 hover:text-red-500 transition-colors p-1.5 hover:bg-red-50 rounded"
            title="Delete"
          >
            <Trash2 className="w-3.5 h-3.5" />
          </button>
        </div>
      ),
      width: '80px',
    },
  ];

  return (
    <div className="h-full flex flex-col bg-white overflow-hidden">
      {loading ? (
        <div className="flex-1 w-full bg-white p-4 overflow-hidden">
           <div className="animate-pulse space-y-4">
             {/* Header Skeleton */}
             <div className="h-10 bg-slate-100 rounded-lg w-full mb-6"></div>
             
             {/* Rows Skeleton */}
             {[...Array(10)].map((_, i) => (
               <div key={i} className="flex gap-4">
                 <div className="h-4 bg-slate-50 rounded w-24"></div>
                 <div className="h-4 bg-slate-50 rounded w-32"></div>
                 <div className="h-4 bg-slate-50 rounded w-40 flex-1"></div>
                 <div className="h-4 bg-slate-50 rounded w-20"></div>
                 <div className="h-4 bg-slate-50 rounded w-24"></div>
               </div>
             ))}
           </div>
        </div>
      ) : (
        <>
          <div className="flex-1 overflow-hidden">
            <Table columns={columns} data={currentCalls} pagination={pagination} keyField="_id" />
          </div>

          <CallModal
            isOpen={isModalOpen}
            onClose={() => {
              setIsModalOpen(false);
              setEditingRecord(null);
            }}
            onSubmit={editingRecord ? handleEditCall : handleAddCall}
            editRecord={editingRecord}
            users={users}
            appointmentSources={appointmentSources}
            inspectionStatuses={inspectionStatuses}
          />

          <DeleteModal
            isOpen={isDeleteModalOpen}
            onClose={() => {
              setIsDeleteModalOpen(false);
              setDeletingRecord(null);
            }}
            onConfirm={handleDeleteCall}
            recordName={deletingRecord?.ownerName}
          />

          <GlobalImportModal
            isOpen={isImportModalOpen}
            onClose={() => setIsImportModalOpen(false)}
            endpoint="/api/telecalling/import"
            onSuccess={() => {
              handleRefresh();
              setTimeout(() => setIsImportModalOpen(false), 1500);
            }}
            title="Import Telecalling Data"
          />
        </>
      )}
    </div>
  );
}
