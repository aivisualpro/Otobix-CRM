'use client';

import { useState, useEffect, useRef, FormEvent } from 'react';
import { X, Search, Plus, Check, ImageIcon, Palette, ChevronDown } from 'lucide-react';
import Image from 'next/image';

// --- Types ---

export interface DropdownItem {
  _id: string;
  description: string;
  type: string;
  icon?: string;
  color?: string;
  isActive: boolean;
  sortOrder: number;
}

// Predefined colors
const PRESET_COLORS = [
  '#ef4444', '#f97316', '#f59e0b', '#eab308', 
  '#84cc16', '#22c55e', '#10b981', '#14b8a6', 
  '#06b6d4', '#0ea5e9', '#3b82f6', '#6366f1', 
  '#8b5cf6', '#a855f7', '#d946ef', '#ec4899', 
  '#f43f5e', '#64748b',
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

  const filteredTypes = existingTypes.filter((t) =>
    t.toLowerCase().includes(searchTerm.toLowerCase())
  );
  const showAddNew =
    searchTerm && !existingTypes.some((t) => t.toLowerCase() === searchTerm.toLowerCase());

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
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className="form-input w-full text-left flex items-center justify-between"
      >
        <span className={value ? 'text-slate-900' : 'text-slate-400'}>
          {value || 'Select or add type...'}
        </span>
        <ChevronDown className="w-4 h-4 text-slate-400" />
      </button>
      {isOpen && (
        <div className="absolute z-50 mt-1 w-full bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-hidden">
          <div className="p-2 border-b border-gray-100">
            <div className="relative">
              <Search className="absolute left-2 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
              <input
                type="text"
                placeholder="Search or add new type..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-8 pr-3 py-1.5 text-sm border border-gray-200 rounded focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                autoFocus
              />
            </div>
          </div>
          <div className="max-h-44 overflow-y-auto">
            {showAddNew && (
              <button
                type="button"
                onClick={() => {
                  onChange(searchTerm);
                  setIsOpen(false);
                  setSearchTerm('');
                }}
                className="w-full px-3 py-2 text-left text-sm text-blue-600 hover:bg-blue-50 flex items-center gap-2"
              >
                <Plus className="w-4 h-4" /> Add &quot;{searchTerm}&quot;
              </button>
            )}
            {filteredTypes.map((type) => (
              <button
                key={type}
                type="button"
                onClick={() => {
                  onChange(type);
                  setIsOpen(false);
                  setSearchTerm('');
                }}
                className={`w-full px-3 py-2 text-left text-sm hover:bg-blue-50 flex items-center justify-between ${
                  value === type ? 'bg-blue-50 text-blue-700' : 'text-slate-700'
                }`}
              >
                {type}
                {value === type && <Check className="w-4 h-4" />}
              </button>
            ))}
            {filteredTypes.length === 0 && !showAddNew && (
              <div className="px-3 py-4 text-center text-sm text-slate-400">No types found</div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

// --- Color Picker ---
interface ColorPickerProps {
  value: string;
  onChange: (color: string) => void;
}

const ColorPicker = ({ value, onChange }: ColorPickerProps) => {
  const [isOpen, setIsOpen] = useState(false);
  const [customColor, setCustomColor] = useState(value || '');
  const dropdownRef = useRef<HTMLDivElement>(null);

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
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className="form-input w-full text-left flex items-center gap-2"
      >
        <div
          className="w-5 h-5 rounded border border-gray-300"
          style={{ backgroundColor: value || '#ffffff' }}
        />
        <span className={value ? 'text-slate-900 font-mono text-sm' : 'text-slate-400'}>
          {value || 'Select color...'}
        </span>
      </button>
      {isOpen && (
        <div className="absolute z-50 mt-1 w-64 bg-white border border-gray-200 rounded-lg shadow-lg p-3">
          <div className="grid grid-cols-6 gap-2 mb-3">
            {PRESET_COLORS.map((color) => (
              <button
                key={color}
                type="button"
                onClick={() => {
                  onChange(color);
                  setIsOpen(false);
                }}
                className={`w-8 h-8 rounded-lg border-2 transition-transform hover:scale-110 ${
                  value === color ? 'border-blue-500 ring-2 ring-blue-200' : 'border-transparent'
                }`}
                style={{ backgroundColor: color }}
              />
            ))}
          </div>
          <div className="flex gap-2">
            <input
              type="text"
              placeholder="#000000"
              value={customColor}
              onChange={(e) => setCustomColor(e.target.value)}
              className="flex-1 px-2 py-1 text-sm border border-gray-200 rounded font-mono"
            />
            <button
              type="button"
              onClick={() => {
                if (customColor) {
                  onChange(customColor);
                  setIsOpen(false);
                }
              }}
              className="px-3 py-1 bg-blue-500 text-white text-sm rounded hover:bg-blue-600"
            >
              Set
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

// --- Dropdown Modal ---

interface DropdownModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: Omit<DropdownItem, '_id' | 'isActive' | 'sortOrder'>) => void;
  existingTypes: string[];
  editItem?: DropdownItem | null;
}

export default function DropdownModal({
  isOpen,
  onClose,
  onSubmit,
  existingTypes,
  editItem,
}: DropdownModalProps) {
  const [selectedType, setSelectedType] = useState(editItem?.type || '');
  const [description, setDescription] = useState(editItem?.description || '');

  // Removed useEffect; Component should be conditionally rendered by parent to reset state


  if (!isOpen) return null;

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    onSubmit({ description, type: selectedType, icon: '', color: '' }); // Pass empty visuals
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
      <div className="bg-white shadow-2xl w-full max-w-lg border border-gray-100 rounded-xl">
        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center">
          <h2 className="text-lg font-bold text-slate-900">
            {editItem ? 'Edit Dropdown Item' : 'Add Dropdown Item'}
          </h2>
          <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-lg">
            <X className="w-5 h-5 text-slate-500" />
          </button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-1">Value *</label>
            <input
              type="text"
              required
              className="form-input"
              placeholder="Enter value..."
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-slate-500 mb-1">Name (Group) *</label>
            <SearchableTypeSelect
              value={selectedType}
              onChange={setSelectedType}
              existingTypes={existingTypes}
            />
          </div>
          <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
            <button type="button" onClick={onClose} className="btn-secondary">
              Cancel
            </button>
            <button type="submit" className="btn-primary" disabled={!selectedType}>
              {editItem ? 'Update' : 'Create'} Dropdown
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
