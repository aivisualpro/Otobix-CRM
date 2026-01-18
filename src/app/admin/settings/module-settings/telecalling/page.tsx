'use client';

import { useState, useEffect } from 'react';
import GlobalImportModal from '@/components/GlobalImportModal';
import { Download, GripVertical, Eye, EyeOff, Save, RotateCcw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Switch } from '@/components/ui/switch';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion';

// All available telecalling columns
const ALL_COLUMNS = [
  { id: 'appointmentId', label: 'Appt ID', defaultVisible: true },
  { id: 'carRegistrationNumber', label: 'Reg. No', defaultVisible: true },
  { id: 'ownerName', label: 'Owner', defaultVisible: true },
  { id: 'city', label: 'City', defaultVisible: true },
  { id: 'allocatedTo', label: 'Allocated To', defaultVisible: true },
  { id: 'inspectionStatus', label: 'Status', defaultVisible: true },
  { id: 'inspectionDateTime', label: 'Inspection Date', defaultVisible: true },
  { id: 'priority', label: 'Priority', defaultVisible: true },
  { id: 'make', label: 'Make', defaultVisible: true },
  { id: 'model', label: 'Model', defaultVisible: true },
  { id: 'variant', label: 'Variant', defaultVisible: true },
  { id: 'customerContactNumber', label: 'Contact', defaultVisible: true },
  { id: 'appointmentSource', label: 'Source', defaultVisible: true },
  { id: 'remarks', label: 'Remarks', defaultVisible: false },
  { id: 'createdBy', label: 'Created By', defaultVisible: false },
  { id: 'createdAt', label: 'Created At', defaultVisible: true },
  { id: 'yearOfRegistration', label: 'Reg. Year', defaultVisible: false },
  { id: 'ownershipSerialNumber', label: 'Ownership Serial', defaultVisible: false },
  { id: 'yearOfManufacture', label: 'Mfg Year', defaultVisible: false },
  { id: 'odometerReadingInKms', label: 'Odometer', defaultVisible: false },
  { id: 'emailAddress', label: 'Email', defaultVisible: false },
  { id: 'zipCode', label: 'Zip Code', defaultVisible: false },
  { id: 'inspectionAddress', label: 'Inspection Address', defaultVisible: false },
  { id: 'vehicleStatus', label: 'Vehicle Status', defaultVisible: false },
  { id: 'ncdUcdName', label: 'NCD/UCD Name', defaultVisible: false },
  { id: 'repName', label: 'Rep Name', defaultVisible: false },
  { id: 'repContact', label: 'Rep Contact', defaultVisible: false },
  { id: 'bankSource', label: 'Bank Source', defaultVisible: false },
  { id: 'referenceName', label: 'Reference Name', defaultVisible: false },
  { id: 'addedBy', label: 'Added By', defaultVisible: false },
  { id: 'additionalNotes', label: 'Additional Notes', defaultVisible: false },
];

interface ColumnConfig {
  id: string;
  label: string;
  visible: boolean;
}

const STORAGE_KEY = 'telecalling_columns_config';

export default function ModuleTelecallingPage() {
  const [isImportModalOpen, setIsImportModalOpen] = useState(false);
  const [columns, setColumns] = useState<ColumnConfig[]>([]);
  const [draggedIndex, setDraggedIndex] = useState<number | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [hasChanges, setHasChanges] = useState(false);

  // Load saved config from MongoDB (primary) or localStorage (fallback)
  useEffect(() => {
    const loadConfig = async () => {
      let savedConfigs: ColumnConfig[] | null = null;

      try {
        // 1. Try fetching from MongoDB API
        const res = await fetch('/api/settings');
        if (res.ok) {
          const settings = await res.json();
          const targetSetting = settings.find((s: any) => s.key === STORAGE_KEY);
          if (targetSetting && targetSetting.value) {
            savedConfigs = typeof targetSetting.value === 'string' 
              ? JSON.parse(targetSetting.value) 
              : targetSetting.value;
            console.log('[TelecallingSettings] Loaded config from MongoDB');
          }
        }
      } catch (err) {
        console.warn('[TelecallingSettings] MongoDB load failed, falling back to localStorage:', err);
      }

      // 2. Fallback to localStorage
      if (!savedConfigs) {
        const saved = localStorage.getItem(STORAGE_KEY);
        if (saved) {
          try {
            savedConfigs = JSON.parse(saved);
            console.log('[TelecallingSettings] Loaded config from localStorage');
          } catch (err) {
            console.error('[TelecallingSettings] Error parsing local storage:', err);
          }
        }
      }

      // 3. Apply the configs (merged with ALL_COLUMNS for new items)
      if (savedConfigs) {
        const mergedColumns = ALL_COLUMNS.map(col => {
          const savedCol = (savedConfigs as ColumnConfig[]).find(s => s.id === col.id);
          return savedCol ? { ...col, visible: savedCol.visible } : { ...col, visible: col.defaultVisible };
        });
        
        const orderedColumns = (savedConfigs as ColumnConfig[])
          .map(s => mergedColumns.find(m => m.id === s.id))
          .filter(Boolean) as ColumnConfig[];
        
        const newColumns = mergedColumns.filter(m => !(savedConfigs as ColumnConfig[]).find(s => s.id === m.id));
        
        setColumns([...orderedColumns, ...newColumns]);
      } else {
        setColumns(ALL_COLUMNS.map(col => ({ ...col, visible: col.defaultVisible })));
      }
    };

    loadConfig();
  }, []);

  const toggleVisibility = (id: string) => {
    setColumns(prev => prev.map(col => col.id === id ? { ...col, visible: !col.visible } : col));
    setHasChanges(true);
  };

  const handleDragStart = (index: number) => {
    setDraggedIndex(index);
  };

  const handleDragOver = (e: React.DragEvent, index: number) => {
    e.preventDefault();
    if (draggedIndex === null || draggedIndex === index) return;
    
    const newColumns = [...columns];
    const draggedItem = newColumns[draggedIndex];
    newColumns.splice(draggedIndex, 1);
    newColumns.splice(index, 0, draggedItem);
    setColumns(newColumns);
    setDraggedIndex(index);
    setHasChanges(true);
  };

  const handleDragEnd = () => {
    setDraggedIndex(null);
  };

  const saveConfig = async () => {
    setIsSaving(true);
    try {
      // 1. Save to MongoDB
      const res = await fetch('/api/settings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          key: STORAGE_KEY,
          value: columns,
          label: 'Telecalling Columns Configuration',
          category: 'Module Configuration',
          type: 'json'
        }),
      });

      // If it fails because it already exists, try PUT
      if (res.status === 400) {
        await fetch('/api/settings', {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            key: STORAGE_KEY,
            value: columns
          }),
        });
      }

      // 2. Save to localStorage as secondary
      localStorage.setItem(STORAGE_KEY, JSON.stringify(columns));
      
      setHasChanges(false);
    } catch (error) {
      console.error('[TelecallingSettings] Save failed:', error);
      alert('Failed to save configuration to database. Local changes applied.');
    } finally {
      setIsSaving(false);
    }
  };

  const resetToDefault = () => {
    setColumns(ALL_COLUMNS.map(col => ({ ...col, visible: col.defaultVisible })));
    setHasChanges(true);
  };

  const visibleCount = columns.filter(c => c.visible).length;

  return (
    <div className="p-6 space-y-6">
      <div className="max-w-4xl mx-auto space-y-4">
        {/* Data Management Section */}
        <Card className="rounded-xl shadow-sm border">
          <CardHeader className="pb-4">
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="text-lg">Data Management</CardTitle>
                <CardDescription>Manage telecalling data imports</CardDescription>
              </div>
              <Button onClick={() => setIsImportModalOpen(true)} className="gap-2">
                <Download className="w-4 h-4" /> Import Data
              </Button>
            </div>
          </CardHeader>
        </Card>

        {/* Column Configuration Section */}
        <Accordion type="single" collapsible className="w-full">
          <AccordionItem value="telecalling-columns" className="bg-white border rounded-xl overflow-hidden shadow-sm">
            <AccordionTrigger className="px-6 py-4 hover:no-underline hover:bg-gray-50/50">
              <div className="flex flex-col items-start gap-1">
                <CardTitle className="text-lg">Telecalling Columns</CardTitle>
                <CardDescription>
                  Select and reorder columns displayed in the telecalling list view ({visibleCount} of {columns.length} visible)
                </CardDescription>
              </div>
            </AccordionTrigger>
            <AccordionContent className="px-6 pb-6 pt-2">
              <div className="flex items-center justify-end gap-2 mb-4">
                <Button variant="outline" size="sm" onClick={resetToDefault} className="gap-2">
                  <RotateCcw className="w-4 h-4" /> Reset
                </Button>
                <Button 
                  size="sm" 
                  onClick={saveConfig} 
                  disabled={!hasChanges || isSaving}
                  className="gap-2"
                >
                  <Save className="w-4 h-4" /> {isSaving ? 'Saving...' : 'Save Changes'}
                </Button>
              </div>

              <div className="border rounded-lg divide-y">
                {columns.map((column, index) => (
                  <div
                    key={column.id}
                    draggable
                    onDragStart={() => handleDragStart(index)}
                    onDragOver={(e) => handleDragOver(e, index)}
                    onDragEnd={handleDragEnd}
                    className={`flex items-center gap-4 px-4 py-3 bg-white hover:bg-gray-50 transition-colors cursor-move ${
                      draggedIndex === index ? 'bg-blue-50 shadow-inner' : ''
                    }`}
                  >
                    <GripVertical className="w-4 h-4 text-gray-400 shrink-0" />
                    <div className="flex-1 flex items-center gap-3">
                      <span className="text-sm font-medium text-slate-700">{column.label}</span>
                      <span className="text-xs text-slate-400 font-mono">{column.id}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      {column.visible ? (
                        <Eye className="w-4 h-4 text-green-500" />
                      ) : (
                        <EyeOff className="w-4 h-4 text-gray-300" />
                      )}
                      <Switch
                        checked={column.visible}
                        onCheckedChange={() => toggleVisibility(column.id)}
                        id={`toggle-${column.id}`}
                      />
                    </div>
                  </div>
                ))}
              </div>
              <p className="text-xs text-slate-500 mt-4">
                Drag and drop to reorder columns. Toggle visibility using the switch. Changes will apply after saving and refreshing the telecalling page.
              </p>
            </AccordionContent>
          </AccordionItem>
        </Accordion>
      </div>

      <GlobalImportModal
        isOpen={isImportModalOpen}
        onClose={() => setIsImportModalOpen(false)}
        endpoint="/api/telecalling/import"
        onSuccess={() => {
          setTimeout(() => setIsImportModalOpen(false), 1500);
        }}
        title="Import Telecalling Data"
      />
    </div>
  );
}

