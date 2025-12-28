'use client';

import { useState, useEffect, FormEvent, useRef } from 'react';
import { 
  Settings as SettingsIcon, Plus, Save, Trash2, X, Edit2,
  ToggleLeft, ToggleRight, Hash, Type, Calendar, List, Code,
  ChevronDown, Image, Palette, Search, Check
} from 'lucide-react';
import { useHeader } from '@/context/HeaderContext';
import Table from '@/components/Table';

// --- Types ---
interface Setting {
  _id: string;
  key: string;
  value: any;
  category: string;
  label: string;
  description?: string;
  type: 'text' | 'number' | 'boolean' | 'select' | 'json' | 'date';
  options?: string[];
}

interface DropdownItem {
  _id: string;
  description: string;
  type: string;
  icon?: string;
  color?: string;
  isActive: boolean;
  sortOrder: number;
}

type ActiveSection = 'settings' | 'dropdowns';

// Predefined colors
const PRESET_COLORS = [
  '#ef4444', '#f97316', '#f59e0b', '#eab308', '#84cc16', '#22c55e',
  '#10b981', '#14b8a6', '#06b6d4', '#0ea5e9', '#3b82f6', '#6366f1',
  '#8b5cf6', '#a855f7', '#d946ef', '#ec4899', '#f43f5e', '#64748b'
];

// Default settings
const DEFAULT_SETTINGS: Omit<Setting, '_id'>[] = [
  { key: 'app_name', value: 'Otobix CRM', category: 'General', label: 'Application Name', description: 'The name displayed in the header', type: 'text' },
  { key: 'items_per_page', value: 20, category: 'Display', label: 'Items Per Page', description: 'Default number of items in tables', type: 'number' },
  { key: 'enable_notifications', value: true, category: 'Notifications', label: 'Enable Notifications', description: 'Toggle system-wide notifications', type: 'boolean' },
  { key: 'default_priority', value: 'Medium', category: 'Telecalling', label: 'Default Priority', description: 'Default priority for new records', type: 'select', options: ['High', 'Medium', 'Low'] },
  { key: 'date_format', value: 'DD/MM/YYYY', category: 'Display', label: 'Date Format', description: 'Format for displaying dates', type: 'select', options: ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'] }
];

// --- Searchable Type Select ---
interface SearchableTypeSelectProps {
  value: string;
  onChange: (value: string) => void;
  existingTypes: string[];
}

const SearchableTypeSelect = ({ value, onChange, existingTypes }: SearchableTypeSelectProps) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const dropdownRef = useRef<HTMLDivElement>(null);

  const filteredTypes = existingTypes.filter(t => t.toLowerCase().includes(searchTerm.toLowerCase()));
  const showAddNew = searchTerm && !existingTypes.some(t => t.toLowerCase() === searchTerm.toLowerCase());

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) setIsOpen(false);
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div className="relative" ref={dropdownRef}>
      <button type="button" onClick={() => setIsOpen(!isOpen)} className="form-input w-full text-left flex items-center justify-between">
        <span className={value ? 'text-slate-900' : 'text-slate-400'}>{value || 'Select or add type...'}</span>
        <ChevronDown className="w-4 h-4 text-slate-400" />
      </button>
      {isOpen && (
        <div className="absolute z-50 mt-1 w-full bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-hidden">
          <div className="p-2 border-b border-gray-100">
            <div className="relative">
              <Search className="absolute left-2 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
              <input type="text" placeholder="Search or add new type..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className="w-full pl-8 pr-3 py-1.5 text-sm border border-gray-200 rounded focus:outline-none focus:ring-2 focus:ring-blue-500/20" autoFocus />
            </div>
          </div>
          <div className="max-h-44 overflow-y-auto">
            {showAddNew && (
              <button type="button" onClick={() => { onChange(searchTerm); setIsOpen(false); setSearchTerm(''); }} className="w-full px-3 py-2 text-left text-sm text-blue-600 hover:bg-blue-50 flex items-center gap-2">
                <Plus className="w-4 h-4" /> Add "{searchTerm}"
              </button>
            )}
            {filteredTypes.map(type => (
              <button key={type} type="button" onClick={() => { onChange(type); setIsOpen(false); setSearchTerm(''); }} className={`w-full px-3 py-2 text-left text-sm hover:bg-blue-50 flex items-center justify-between ${value === type ? 'bg-blue-50 text-blue-700' : 'text-slate-700'}`}>
                {type}
                {value === type && <Check className="w-4 h-4" />}
              </button>
            ))}
            {filteredTypes.length === 0 && !showAddNew && <div className="px-3 py-4 text-center text-sm text-slate-400">No types found</div>}
          </div>
        </div>
      )}
    </div>
  );
};

// --- Color Picker ---
interface ColorPickerProps { value: string; onChange: (color: string) => void; }

const ColorPicker = ({ value, onChange }: ColorPickerProps) => {
  const [isOpen, setIsOpen] = useState(false);
  const [customColor, setCustomColor] = useState(value || '');
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) setIsOpen(false);
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div className="relative" ref={dropdownRef}>
      <button type="button" onClick={() => setIsOpen(!isOpen)} className="form-input w-full text-left flex items-center gap-2">
        <div className="w-5 h-5 rounded border border-gray-300" style={{ backgroundColor: value || '#ffffff' }} />
        <span className={value ? 'text-slate-900 font-mono text-sm' : 'text-slate-400'}>{value || 'Select color...'}</span>
      </button>
      {isOpen && (
        <div className="absolute z-50 mt-1 w-64 bg-white border border-gray-200 rounded-lg shadow-lg p-3">
          <div className="grid grid-cols-6 gap-2 mb-3">
            {PRESET_COLORS.map(color => (
              <button key={color} type="button" onClick={() => { onChange(color); setIsOpen(false); }} className={`w-8 h-8 rounded-lg border-2 transition-transform hover:scale-110 ${value === color ? 'border-blue-500 ring-2 ring-blue-200' : 'border-transparent'}`} style={{ backgroundColor: color }} />
            ))}
          </div>
          <div className="flex gap-2">
            <input type="text" placeholder="#000000" value={customColor} onChange={(e) => setCustomColor(e.target.value)} className="flex-1 px-2 py-1 text-sm border border-gray-200 rounded font-mono" />
            <button type="button" onClick={() => { if (customColor) { onChange(customColor); setIsOpen(false); } }} className="px-3 py-1 bg-blue-500 text-white text-sm rounded hover:bg-blue-600">Set</button>
          </div>
        </div>
      )}
    </div>
  );
};

// --- Setting Card ---
interface SettingCardProps { setting: Setting; onUpdate: (key: string, value: any) => void; onDelete: (id: string) => void; }

const SettingCard = ({ setting, onUpdate, onDelete }: SettingCardProps) => {
  const [localValue, setLocalValue] = useState(setting.value);
  const [hasChanges, setHasChanges] = useState(false);

  useEffect(() => { setLocalValue(setting.value); setHasChanges(false); }, [setting.value]);

  const handleChange = (newValue: any) => { setLocalValue(newValue); setHasChanges(JSON.stringify(newValue) !== JSON.stringify(setting.value)); };
  const handleSave = () => { onUpdate(setting.key, localValue); setHasChanges(false); };

  const getIcon = () => {
    switch (setting.type) {
      case 'boolean': return <ToggleLeft className="w-4 h-4" />;
      case 'number': return <Hash className="w-4 h-4" />;
      case 'date': return <Calendar className="w-4 h-4" />;
      case 'select': return <List className="w-4 h-4" />;
      case 'json': return <Code className="w-4 h-4" />;
      default: return <Type className="w-4 h-4" />;
    }
  };

  const renderInput = () => {
    switch (setting.type) {
      case 'boolean':
        return <button type="button" onClick={() => handleChange(!localValue)} className={`flex items-center gap-2 px-4 py-2 rounded-lg ${localValue ? 'bg-emerald-100 text-emerald-700' : 'bg-gray-100 text-gray-500'}`}>{localValue ? <><ToggleRight className="w-5 h-5" /> Enabled</> : <><ToggleLeft className="w-5 h-5" /> Disabled</>}</button>;
      case 'number': return <input type="number" value={localValue} onChange={(e) => handleChange(parseInt(e.target.value) || 0)} className="form-input w-40" />;
      case 'select': return <select value={localValue} onChange={(e) => handleChange(e.target.value)} className="form-input w-48">{setting.options?.map(opt => <option key={opt} value={opt}>{opt}</option>)}</select>;
      case 'date': return <input type="date" value={localValue} onChange={(e) => handleChange(e.target.value)} className="form-input w-48" />;
      case 'json': return <textarea value={typeof localValue === 'string' ? localValue : JSON.stringify(localValue, null, 2)} onChange={(e) => { try { handleChange(JSON.parse(e.target.value)); } catch { handleChange(e.target.value); } }} className="form-input w-full h-24 font-mono text-xs" />;
      default: return <input type="text" value={localValue} onChange={(e) => handleChange(e.target.value)} className="form-input w-64" />;
    }
  };

  return (
    <div className="bg-white border border-gray-100 rounded-xl p-4 hover:shadow-md transition-shadow">
      <div className="flex items-start justify-between gap-4">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <span className="text-blue-500">{getIcon()}</span>
            <h4 className="font-semibold text-slate-800">{setting.label}</h4>
            <span className="text-[10px] px-2 py-0.5 bg-gray-100 text-gray-500 rounded font-mono">{setting.key}</span>
          </div>
          {setting.description && <p className="text-xs text-slate-500 mb-3">{setting.description}</p>}
          <div className="flex items-center gap-3">
            {renderInput()}
            {hasChanges && <button onClick={handleSave} className="flex items-center gap-1 px-3 py-1.5 bg-blue-500 text-white text-xs font-medium rounded-lg hover:bg-blue-600"><Save className="w-3 h-3" /> Save</button>}
          </div>
        </div>
        <button onClick={() => onDelete(setting._id)} className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-lg"><Trash2 className="w-4 h-4" /></button>
      </div>
    </div>
  );
};

// --- Add Setting Modal ---
interface AddSettingModalProps { isOpen: boolean; onClose: () => void; onSubmit: (data: Omit<Setting, '_id'>) => void; }

const AddSettingModal = ({ isOpen, onClose, onSubmit }: AddSettingModalProps) => {
  const [selectedType, setSelectedType] = useState<Setting['type']>('text');
  const [optionsText, setOptionsText] = useState('');

  if (!isOpen) return null;

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    let value: any = formData.get('value') as string;
    if (selectedType === 'number') value = parseInt(value) || 0;
    if (selectedType === 'boolean') value = value === 'true';
    if (selectedType === 'json') { try { value = JSON.parse(value); } catch { } }

    onSubmit({
      key: (formData.get('key') as string).toLowerCase().replace(/\s+/g, '_'),
      value,
      category: formData.get('category') as string || 'General',
      label: formData.get('label') as string,
      description: formData.get('description') as string,
      type: selectedType,
      options: selectedType === 'select' ? optionsText.split(',').map(o => o.trim()).filter(Boolean) : []
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
      <div className="bg-white shadow-2xl w-full max-w-lg border border-gray-100 rounded-xl">
        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center">
          <h2 className="text-lg font-bold text-slate-900">Add New Setting</h2>
          <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-lg"><X className="w-5 h-5 text-slate-500" /></button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div><label className="block text-xs font-semibold text-slate-500 mb-1">Key (unique)</label><input name="key" type="text" required className="form-input" placeholder="my_setting_key" /></div>
            <div><label className="block text-xs font-semibold text-slate-500 mb-1">Label</label><input name="label" type="text" required className="form-input" placeholder="My Setting" /></div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div><label className="block text-xs font-semibold text-slate-500 mb-1">Category</label><input name="category" type="text" className="form-input" placeholder="General" defaultValue="General" /></div>
            <div><label className="block text-xs font-semibold text-slate-500 mb-1">Type</label><select name="type" className="form-input" value={selectedType} onChange={(e) => setSelectedType(e.target.value as Setting['type'])}><option value="text">Text</option><option value="number">Number</option><option value="boolean">Boolean</option><option value="select">Select</option><option value="date">Date</option><option value="json">JSON</option></select></div>
          </div>
          <div><label className="block text-xs font-semibold text-slate-500 mb-1">Description</label><input name="description" type="text" className="form-input" placeholder="Optional..." /></div>
          {selectedType === 'select' && <div><label className="block text-xs font-semibold text-slate-500 mb-1">Options (comma separated)</label><input type="text" className="form-input" value={optionsText} onChange={(e) => setOptionsText(e.target.value)} /></div>}
          <div><label className="block text-xs font-semibold text-slate-500 mb-1">Default Value</label>{selectedType === 'boolean' ? <select name="value" className="form-input"><option value="true">Enabled</option><option value="false">Disabled</option></select> : selectedType === 'json' ? <textarea name="value" className="form-input h-20 font-mono text-xs" /> : <input name="value" type={selectedType === 'number' ? 'number' : 'text'} className="form-input" />}</div>
          <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
            <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
            <button type="submit" className="btn-primary">Create Setting</button>
          </div>
        </form>
      </div>
    </div>
  );
};

// --- Add/Edit Dropdown Modal ---
interface DropdownModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: Omit<DropdownItem, '_id' | 'isActive' | 'sortOrder'>) => void;
  existingTypes: string[];
  editItem?: DropdownItem | null;
}

const DropdownModal = ({ isOpen, onClose, onSubmit, existingTypes, editItem }: DropdownModalProps) => {
  const [selectedType, setSelectedType] = useState(editItem?.type || '');
  const [selectedColor, setSelectedColor] = useState(editItem?.color || '');
  const [iconUrl, setIconUrl] = useState(editItem?.icon || '');
  const [description, setDescription] = useState(editItem?.description || '');

  useEffect(() => {
    if (editItem) {
      setSelectedType(editItem.type);
      setSelectedColor(editItem.color || '');
      setIconUrl(editItem.icon || '');
      setDescription(editItem.description);
    } else {
      setSelectedType('');
      setSelectedColor('');
      setIconUrl('');
      setDescription('');
    }
  }, [editItem, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    onSubmit({ description, type: selectedType, icon: iconUrl, color: selectedColor });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
      <div className="bg-white shadow-2xl w-full max-w-lg border border-gray-100 rounded-xl">
        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center">
          <h2 className="text-lg font-bold text-slate-900">{editItem ? 'Edit Dropdown Item' : 'Add Dropdown Item'}</h2>
          <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-lg"><X className="w-5 h-5 text-slate-500" /></button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-1">Description *</label>
            <input type="text" required className="form-input" placeholder="Enter description..." value={description} onChange={(e) => setDescription(e.target.value)} />
          </div>
          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-1">Type *</label>
            <SearchableTypeSelect value={selectedType} onChange={setSelectedType} existingTypes={existingTypes} />
          </div>
          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-1"><span className="flex items-center gap-1"><Image className="w-3 h-3" /> Icon (URL)</span></label>
            <input type="text" className="form-input" placeholder="https://example.com/icon.png" value={iconUrl} onChange={(e) => setIconUrl(e.target.value)} />
            {iconUrl && <div className="mt-2 p-2 bg-gray-50 rounded-lg inline-block"><img src={iconUrl} alt="Preview" className="w-8 h-8 object-contain" /></div>}
          </div>
          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-1"><span className="flex items-center gap-1"><Palette className="w-3 h-3" /> Color</span></label>
            <ColorPicker value={selectedColor} onChange={setSelectedColor} />
          </div>
          <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
            <button type="button" onClick={onClose} className="btn-secondary">Cancel</button>
            <button type="submit" className="btn-primary" disabled={!selectedType}>{editItem ? 'Update' : 'Create'} Dropdown</button>
          </div>
        </form>
      </div>
    </div>
  );
};

// --- Main Page ---
export default function SettingsPage() {
  const { setTitle, setSearchContent, setActionsContent } = useHeader();
  
  const [activeSection, setActiveSection] = useState<ActiveSection>('settings');
  const [settings, setSettings] = useState<Setting[]>([]);
  const [dropdowns, setDropdowns] = useState<DropdownItem[]>([]);
  const [dropdownTypes, setDropdownTypes] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [isAddSettingModalOpen, setIsAddSettingModalOpen] = useState(false);
  const [isDropdownModalOpen, setIsDropdownModalOpen] = useState(false);
  const [editingDropdown, setEditingDropdown] = useState<DropdownItem | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [selectedType, setSelectedType] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');

  // Fetch
  const fetchSettings = async () => {
    try {
      const res = await fetch('/api/settings', { cache: 'no-store' });
      if (res.ok) setSettings(await res.json());
    } catch { }
  };

  const fetchDropdowns = async () => {
    try {
      const [itemsRes, typesRes] = await Promise.all([fetch('/api/dropdowns', { cache: 'no-store' }), fetch('/api/dropdowns/types', { cache: 'no-store' })]);
      if (itemsRes.ok) setDropdowns(await itemsRes.json());
      if (typesRes.ok) setDropdownTypes(await typesRes.json());
    } catch { }
  };

  const seedDefaults = async () => {
    for (const s of DEFAULT_SETTINGS) { try { await fetch('/api/settings', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(s) }); } catch { } }
    fetchSettings();
  };

  useEffect(() => {
    const load = async () => { setLoading(true); await Promise.all([fetchSettings(), fetchDropdowns()]); setLoading(false); };
    load();
  }, []);

  useEffect(() => { if (!loading && settings.length === 0) seedDefaults(); }, [loading, settings.length]);

  // Header - title, search, and action button
  useEffect(() => {
    setTitle('System Settings');
    setSearchContent(
      <div className="relative group w-full max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
        <input type="text" placeholder="Search..." className="w-full pl-9 pr-4 py-1.5 bg-gray-50 border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-xs rounded-lg" value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} />
      </div>
    );
    setActionsContent(
      activeSection === 'dropdowns' ? (
        <button
          onClick={() => { setEditingDropdown(null); setIsDropdownModalOpen(true); }}
          className="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white text-sm font-medium rounded-lg shadow-lg shadow-blue-500/20 hover:bg-blue-600 transition-colors"
        >
          <Plus className="w-4 h-4" /> Add Dropdown
        </button>
      ) : null
    );
  }, [setTitle, setSearchContent, setActionsContent, searchTerm, activeSection]);

  // Handlers
  const handleUpdateSetting = async (key: string, value: any) => {
    const res = await fetch('/api/settings', { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ key, value }) });
    if (res.ok) setSettings(prev => prev.map(s => s.key === key ? { ...s, value } : s));
  };

  const handleDeleteSetting = async (id: string) => {
    if (!confirm('Delete this setting?')) return;
    const res = await fetch(`/api/settings/${id}`, { method: 'DELETE' });
    if (res.ok) setSettings(prev => prev.filter(s => s._id !== id));
  };

  const handleAddSetting = async (data: Omit<Setting, '_id'>) => {
    const res = await fetch('/api/settings', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data) });
    if (res.ok) { fetchSettings(); setIsAddSettingModalOpen(false); }
  };

  const handleUpdateDropdown = async (id: string, data: Partial<DropdownItem>) => {
    const res = await fetch(`/api/dropdowns/${id}`, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data) });
    if (res.ok) setDropdowns(prev => prev.map(d => d._id === id ? { ...d, ...data } : d));
  };

  const handleDeleteDropdown = async (id: string) => {
    if (!confirm('Delete this dropdown item?')) return;
    const res = await fetch(`/api/dropdowns/${id}`, { method: 'DELETE' });
    if (res.ok) { setDropdowns(prev => prev.filter(d => d._id !== id)); fetchDropdowns(); }
  };

  const handleSaveDropdown = async (data: Omit<DropdownItem, '_id' | 'isActive' | 'sortOrder'>) => {
    if (editingDropdown) {
      await handleUpdateDropdown(editingDropdown._id, data);
    } else {
      await fetch('/api/dropdowns', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data) });
    }
    fetchDropdowns();
    setIsDropdownModalOpen(false);
    setEditingDropdown(null);
  };

  const openEditDropdown = (item: DropdownItem) => {
    setEditingDropdown(item);
    setIsDropdownModalOpen(true);
  };

  // Filter
  const settingCategories = [...new Set(settings.map(s => s.category || 'General'))].sort();
  const filteredSettings = settings.filter(s => {
    const matchCat = !selectedCategory || s.category === selectedCategory;
    const matchSearch = !searchTerm || s.label.toLowerCase().includes(searchTerm.toLowerCase()) || s.key.toLowerCase().includes(searchTerm.toLowerCase());
    return matchCat && matchSearch;
  });

  const filteredDropdowns = dropdowns.filter(d => {
    const matchType = !selectedType || d.type === selectedType;
    const matchSearch = !searchTerm || d.description.toLowerCase().includes(searchTerm.toLowerCase()) || d.type.toLowerCase().includes(searchTerm.toLowerCase());
    return matchType && matchSearch;
  });

  // Dropdown Table Columns
  const dropdownColumns = [
    {
      header: '',
      render: (row: DropdownItem) => (
        <div className="flex items-center gap-2">
          {row.color && <div className="w-5 h-5 rounded" style={{ backgroundColor: row.color }} />}
          {row.icon && <img src={row.icon} alt="" className="w-5 h-5 object-contain" />}
        </div>
      ),
      width: '50px'
    },
    { header: 'Description', accessor: 'description' as keyof DropdownItem, className: 'font-medium text-slate-800' },
    {
      header: 'Type',
      render: (row: DropdownItem) => <span className="px-2 py-0.5 bg-blue-100 text-blue-600 text-[10px] font-medium rounded">{row.type}</span>,
      width: '100px'
    },
    {
      header: 'Status',
      render: (row: DropdownItem) => (
        <button onClick={() => handleUpdateDropdown(row._id, { isActive: !row.isActive })} className={`flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-medium ${row.isActive ? 'bg-emerald-100 text-emerald-700' : 'bg-gray-100 text-gray-500'}`}>
          {row.isActive ? <><ToggleRight className="w-3 h-3" /> Active</> : <><ToggleLeft className="w-3 h-3" /> Off</>}
        </button>
      ),
      width: '70px'
    },
    {
      header: '',
      align: 'right' as const,
      render: (row: DropdownItem) => (
        <div className="flex items-center justify-end gap-1">
          <button onClick={() => openEditDropdown(row)} className="p-1 text-slate-400 hover:text-blue-500 hover:bg-blue-50 rounded"><Edit2 className="w-3 h-3" /></button>
          <button onClick={() => handleDeleteDropdown(row._id)} className="p-1 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded"><Trash2 className="w-3 h-3" /></button>
        </div>
      ),
      width: '50px'
    }
  ];

  const sidebarSections = [
    { id: 'settings' as const, label: 'Settings', icon: SettingsIcon },
    { id: 'dropdowns' as const, label: 'Dropdowns', icon: List }
  ];

  return (
    <div className="h-full flex bg-slate-50 overflow-hidden">
      {/* Sidebar */}
      <div className="w-64 bg-white border-r border-gray-200 flex flex-col shrink-0">
        <div className="p-4 border-b border-gray-100">
          <h2 className="text-lg font-bold text-slate-800 flex items-center gap-2"><SettingsIcon className="w-5 h-5 text-blue-500" /> Configuration</h2>
        </div>

        <div className="p-3">
          {sidebarSections.map(section => (
            <button key={section.id} onClick={() => { setActiveSection(section.id); setSelectedCategory(null); setSelectedType(null); }} className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors mb-1 ${activeSection === section.id ? 'bg-blue-50 text-blue-600' : 'text-slate-600 hover:bg-gray-50'}`}>
              <section.icon className="w-4 h-4" /> {section.label}
            </button>
          ))}
        </div>

        <div className="flex-1 overflow-y-auto p-3 border-t border-gray-100">
          <div className="flex items-center justify-between px-3 mb-2">
            <div className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">{activeSection === 'settings' ? 'Categories' : 'Types'}</div>
            <button onClick={() => activeSection === 'settings' ? setIsAddSettingModalOpen(true) : (setEditingDropdown(null), setIsDropdownModalOpen(true))} className="p-1 text-blue-500 hover:bg-blue-50 rounded" title="Add New">
              <Plus className="w-4 h-4" />
            </button>
          </div>

          {activeSection === 'settings' ? (
            <>
              <button onClick={() => setSelectedCategory(null)} className={`w-full text-left px-3 py-2 rounded-lg text-sm transition-colors mb-1 ${selectedCategory === null ? 'bg-blue-100 text-blue-700 font-medium' : 'text-slate-600 hover:bg-gray-50'}`}>All ({settings.length})</button>
              {settingCategories.map(cat => <button key={cat} onClick={() => setSelectedCategory(cat)} className={`w-full text-left px-3 py-2 rounded-lg text-sm transition-colors mb-1 ${selectedCategory === cat ? 'bg-blue-100 text-blue-700 font-medium' : 'text-slate-600 hover:bg-gray-50'}`}>{cat} ({settings.filter(s => s.category === cat).length})</button>)}
            </>
          ) : (
            <>
              <button onClick={() => setSelectedType(null)} className={`w-full text-left px-3 py-2 rounded-lg text-sm transition-colors mb-1 ${selectedType === null ? 'bg-blue-100 text-blue-700 font-medium' : 'text-slate-600 hover:bg-gray-50'}`}>All ({dropdowns.length})</button>
              {dropdownTypes.map(type => <button key={type} onClick={() => setSelectedType(type)} className={`w-full text-left px-3 py-2 rounded-lg text-sm transition-colors mb-1 ${selectedType === type ? 'bg-blue-100 text-blue-700 font-medium' : 'text-slate-600 hover:bg-gray-50'}`}>{type} ({dropdowns.filter(d => d.type === type).length})</button>)}
            </>
          )}
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 overflow-hidden flex flex-col">
        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="w-10 h-10 border-4 border-blue-200 border-t-blue-500 rounded-full animate-spin" />
          </div>
        ) : activeSection === 'settings' ? (
          <div className="flex-1 overflow-y-auto p-6">
            <div className="max-w-3xl space-y-4">
              <div className="mb-6">
                <h2 className="text-xl font-bold text-slate-800">{selectedCategory || 'All Settings'}</h2>
                <p className="text-sm text-slate-500 mt-1">{selectedCategory ? `Settings in ${selectedCategory}` : 'Configure global application settings'}</p>
              </div>
              {filteredSettings.length > 0 ? filteredSettings.map(s => <SettingCard key={s._id} setting={s} onUpdate={handleUpdateSetting} onDelete={handleDeleteSetting} />) : <div className="text-center py-12 text-slate-400"><SettingsIcon className="w-12 h-12 mx-auto mb-4 opacity-50" /><p>No settings found</p></div>}
            </div>
          </div>
        ) : (
          <div className="flex-1 overflow-y-auto p-4">
            <table className="w-full text-left">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="py-2 px-2 text-[10px] font-bold text-slate-500 uppercase w-10"></th>
                  <th className="py-2 px-2 text-[10px] font-bold text-slate-500 uppercase w-110">Description</th>
                  <th className="py-2 px-2 text-[10px] font-bold text-slate-500 uppercase">Type</th>
                  <th className="py-2 px-2 text-[10px] font-bold text-slate-500 uppercase w-20">Status</th>
                  <th className="py-2 px-2 text-[10px] font-bold text-slate-500 uppercase w-16"></th>
                </tr>
              </thead>
              <tbody>
                {filteredDropdowns.length > 0 ? filteredDropdowns.map(row => (
                  <tr key={row._id} className="border-b border-gray-50 hover:bg-gray-50/50">
                    <td className="py-2 px-2">
                      <div className="flex items-center gap-1">
                        {row.color && <div className="w-5 h-5 rounded" style={{ backgroundColor: row.color }} />}
                        {row.icon && <img src={row.icon} alt="" className="w-5 h-5 object-contain" />}
                      </div>
                    </td>
                    <td className="py-2 px-2 text-sm font-medium text-slate-800">{row.description}</td>
                    <td className="py-2 px-2 text-sm text-slate-600 whitespace-nowrap">{row.type}</td>
                    <td className="py-2 px-2">
                      <button onClick={() => handleUpdateDropdown(row._id, { isActive: !row.isActive })} className={`flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-medium ${row.isActive ? 'bg-emerald-100 text-emerald-700' : 'bg-gray-100 text-gray-500'}`}>
                        {row.isActive ? <><ToggleRight className="w-3 h-3" /> Active</> : <><ToggleLeft className="w-3 h-3" /> Off</>}
                      </button>
                    </td>
                    <td className="py-2 px-2">
                      <div className="flex items-center justify-end gap-1">
                        <button onClick={() => openEditDropdown(row)} className="p-1 text-slate-400 hover:text-blue-500 hover:bg-blue-50 rounded"><Edit2 className="w-3 h-3" /></button>
                        <button onClick={() => handleDeleteDropdown(row._id)} className="p-1 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded"><Trash2 className="w-3 h-3" /></button>
                      </div>
                    </td>
                  </tr>
                )) : (
                  <tr>
                    <td colSpan={5} className="py-12 text-center text-slate-400">
                      <List className="w-10 h-10 mx-auto mb-3 opacity-50" />
                      <p className="text-sm">No dropdown items</p>
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <AddSettingModal isOpen={isAddSettingModalOpen} onClose={() => setIsAddSettingModalOpen(false)} onSubmit={handleAddSetting} />
      <DropdownModal isOpen={isDropdownModalOpen} onClose={() => { setIsDropdownModalOpen(false); setEditingDropdown(null); }} onSubmit={handleSaveDropdown} existingTypes={dropdownTypes} editItem={editingDropdown} />
    </div>
  );
}
