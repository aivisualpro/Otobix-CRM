'use client';

import { useState, useEffect, useRef, useMemo, useCallback, FormEvent } from 'react';
import Image from 'next/image';
import { useSession } from 'next-auth/react';
import {
  Search,
  Plus,
  Filter,
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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
  CommandSeparator,
} from "@/components/ui/command"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { Button } from "@/components/ui/button"
import { Check, ChevronsUpDown } from "lucide-react"
import { cn } from "@/lib/utils"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { ScrollArea } from "@/components/ui/scroll-area"

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
  const lowerStatus = status.toLowerCase();
  if (lowerStatus === 'scheduled') colors = 'bg-blue-100 text-blue-700';
  else if (lowerStatus === 'pending') colors = 'bg-yellow-100 text-yellow-700';
  else if (lowerStatus === 'completed') colors = 'bg-emerald-100 text-emerald-700';
  else if (lowerStatus === 'cancelled') colors = 'bg-red-100 text-red-700';

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

// Searchable User Select Component (Shadcn)
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
  const [open, setOpen] = useState(false)
  const [value, setValue] = useState(defaultValue)

  // Find selected user display name
  const selectedUser = users.find((u) => u.userName === value || u.email === value)
  
  // Update value if defaultValue changes externally
  useEffect(() => {
    setValue(defaultValue);
  }, [defaultValue]);

  return (
    <div className="relative">
      <input type="hidden" name={name} value={value} />
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            role="combobox"
            aria-expanded={open}
            className="w-full justify-between font-normal text-slate-900 border-gray-200"
          >
            {selectedUser ? selectedUser.userName : (value || "Select User")}
            <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-[300px] p-0" align="start">
          <Command>
            <CommandInput placeholder={placeholder} />
            <CommandList>
              <CommandEmpty>No users found.</CommandEmpty>
              <CommandGroup>
                <CommandItem
                  value="__clear_selection__"
                  onSelect={() => {
                     setValue("")
                     setOpen(false)
                     if (onSelect) onSelect(null)
                  }}
                  className="text-slate-500"
                >
                  <Check
                    className={cn(
                      "mr-2 h-4 w-4",
                      value === "" ? "opacity-100" : "opacity-0"
                    )}
                  />
                  -- Clear Selection --
                </CommandItem>
                {users.map((user) => (
                  <CommandItem
                    key={user._id}
                    value={user.userName}
                    onSelect={(currentValue) => {
                      // CommandItem often uses lowercase value for filtering, 
                      // but we want to retain case or match by ID if possible.
                      // Here we use user.userName as value.
                      setValue(user.userName)
                      setOpen(false)
                      if (onSelect) onSelect(user)
                    }}
                  >
                    <Check
                      className={cn(
                        "mr-2 h-4 w-4",
                        value === user.userName ? "opacity-100" : "opacity-0"
                      )}
                    />
                    {user.userName}
                  </CommandItem>
                ))}
              </CommandGroup>
            </CommandList>
          </Command>
        </PopoverContent>
      </Popover>
    </div>
  );
};

// Searchable Dropdown Select (Shadcn)
interface SearchableDropdownSelectProps {
  name: string;
  options: DropdownOption[];
  defaultValue?: string;
  placeholder?: string;
  onValueChange?: (value: string) => void;
}

const SearchableDropdownSelect = ({
  name,
  options,
  defaultValue = '',
  placeholder = 'Search...',
  onValueChange,
}: SearchableDropdownSelectProps) => {
  const [open, setOpen] = useState(false);
  const [value, setValue] = useState(defaultValue);
  const [searchQuery, setSearchQuery] = useState("");

  const selectedOption = options.find((o) => o.description === value);
  
  // Update value if defaultValue changes externally
  useEffect(() => {
    setValue(defaultValue);
  }, [defaultValue]);
  
  // Custom filter to allow "Add new" logic visualization if needed
  // But standard Command should suffice if we just show a create button on empty
  
  return (
    <div className="relative">
      <input type="hidden" name={name} value={value} />
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            role="combobox"
            aria-expanded={open}
            className="w-full justify-between font-normal text-slate-900 border-gray-200 bg-white"
          >
            <div className="flex items-center gap-2 overflow-hidden">
                {selectedOption?.color && (
                <div className="w-4 h-4 rounded shrink-0" style={{ backgroundColor: selectedOption.color }} />
                )}
                {selectedOption?.icon && (
                <div className="relative w-4 h-4 shrink-0">
                  <Image src={selectedOption.icon} alt="" fill className="object-contain" />
                </div>
                )}
                <span className="truncate">{value || "Select..."}</span>
            </div>
            <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-[250px] p-0" align="start">
          <Command shouldFilter={false}>
            <CommandInput 
                placeholder={placeholder} 
                value={searchQuery}
                onValueChange={setSearchQuery}
            />
            <CommandList className="max-h-[200px] overflow-y-auto">
                {/* Custom filtering logic since we need 'Add new' */}
                {(() => {
                    const filtered = options.filter(o => o.description.toLowerCase().includes(searchQuery.toLowerCase()));
                    const exactMatch = options.some(o => o.description.toLowerCase() === searchQuery.toLowerCase());
                    
                    return (
                        <>
                            <CommandGroup>
                                <CommandItem
                                    value="__clear__"
                                    onSelect={() => {
                                        setValue("");
                                        setOpen(false);
                                    }}
                                    className="text-slate-500"
                                >
                                    -- Clear --
                                </CommandItem>
                                {filtered.map((opt) => (
                                    <CommandItem
                                        key={opt._id}
                                        value={opt.description}
                                        onSelect={(currentValue) => {
                                            setValue(opt.description);
                                            setOpen(false);
                                            setSearchQuery("");
                                            if (onValueChange) onValueChange(opt.description);
                                        }}
                                    >
                                        <Check
                                            className={cn(
                                                "mr-2 h-4 w-4",
                                                value === opt.description ? "opacity-100" : "opacity-0"
                                            )}
                                        />
                                        <div className="flex items-center gap-2">
                                            {opt.color && (
                                                <div className="w-4 h-4 rounded" style={{ backgroundColor: opt.color }} />
                                            )}
                                            {opt.icon && (
                                              <div className="relative w-4 h-4">
                                                <Image src={opt.icon} alt="" fill className="object-contain" />
                                              </div>
                                            )}
                                            {opt.description}
                                        </div>
                                    </CommandItem>
                                ))}
                            </CommandGroup>
                            
                            {searchQuery && !exactMatch && (
                                <>
                                    <CommandSeparator />
                                    <CommandGroup>
                                        <CommandItem
                                            onSelect={() => {
                                                setValue(searchQuery);
                                                setOpen(false);
                                                setSearchQuery("");
                                                if (onValueChange) onValueChange(searchQuery);
                                            }}
                                            className="text-blue-600 cursor-pointer"
                                        >
                                            <Plus className="mr-2 h-4 w-4" />
                                            Add &quot;{searchQuery}&quot;
                                        </CommandItem>
                                    </CommandGroup>
                                </>
                            )}
                            
                             {filtered.length === 0 && !searchQuery && (
                                <div className="py-6 text-center text-sm text-muted-foreground">No options found.</div>
                             )}
                        </>
                    )
                })()}
            </CommandList>
          </Command>
        </PopoverContent>
      </Popover>
    </div>
  );
};

interface CallModalProps {
  isOpen: boolean;
  onClose: () => void;

  onSubmit: (data: Partial<TelecallingRecord>, files?: File[]) => void;
  editRecord: TelecallingRecord | null;
  title?: string;
  users?: UserOption[];
  appointmentSources?: DropdownOption[];
  inspectionStatuses?: DropdownOption[];
  carVariances?: CarVarianceData[];
}

interface CarVarianceData {
  _id: string;
  make: string;
  model: string;
  variant: string;
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
  carVariances = [],
}: CallModalProps) => {
  const [engineerNumber, setEngineerNumber] = useState(editRecord?.inspectionEngineerNumber || '');
  const [selectedMake, setSelectedMake] = useState(editRecord?.make || '');
  const [selectedModel, setSelectedModel] = useState(editRecord?.model || '');

  // Reset Make/Model when editRecord changes
  useEffect(() => {
    if (isOpen) {
        // eslint-disable-next-line react-hooks/exhaustive-deps
        setSelectedMake(editRecord?.make || '');
        // eslint-disable-next-line react-hooks/exhaustive-deps
        setSelectedModel(editRecord?.model || '');
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [editRecord, isOpen]);

  // Derived Options
  const makeOptions = useMemo(() => {
    const uniqueMakes = Array.from(new Set(carVariances.map(c => c.make))).filter(Boolean).sort();
    return uniqueMakes.map(m => ({
        _id: m,
        description: m,
        type: 'text',
        isActive: true
    }));
  }, [carVariances]);

  const modelOptions = useMemo(() => {
    if (!selectedMake) return [];
    const uniqueModels = Array.from(new Set(carVariances
        .filter(c => c.make === selectedMake)
        .map(c => c.model)
    )).filter(Boolean).sort();
    return uniqueModels.map(m => ({
        _id: m,
        description: m,
        type: 'text',
        isActive: true
    }));
  }, [carVariances, selectedMake]);

  const variantOptions = useMemo(() => {
     if (!selectedMake || !selectedModel) return [];
     const uniqueVariants = Array.from(new Set(carVariances
        .filter(c => c.make === selectedMake && c.model === selectedModel)
        .map(c => c.variant)
     )).filter(Boolean).sort();
     return uniqueVariants.map(v => ({
        _id: v,
        description: v,
        type: 'text',
        isActive: true
     }));
  }, [carVariances, selectedMake, selectedModel]);



  const [priority, setPriority] = useState(editRecord?.priority || 'Medium');
  const [addedBy, setAddedBy] = useState(editRecord?.addedBy || 'Telecaller');



  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      const filesArr = Array.from(e.target.files);
      if (filesArr.length + selectedFiles.length > 5) {
        alert('Maximum 5 images allowed');
        return;
      }
      setSelectedFiles(prev => [...prev, ...filesArr]);
    }
  };

  const removeFile = (index: number) => {
    setSelectedFiles(prev => prev.filter((_, i) => i !== index));
  };

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
    onSubmit(callData, selectedFiles);
  };

  return (
    <Dialog open={isOpen} onOpenChange={(val) => !val && onClose()}>
      <DialogContent className="sm:max-w-4xl h-[90vh] flex flex-col p-0 gap-0 overflow-hidden">
        <DialogHeader className="px-6 py-4 border-b border-gray-100 shrink-0">
          <DialogTitle className="text-xl font-bold text-slate-900">
             {title || (editRecord ? 'Edit Record' : 'Add Lead Call Record')}
          </DialogTitle>
          <DialogDescription className="text-xs text-slate-500 mt-0.5">
            {editRecord
                ? 'Update the record details'
                : 'Enter details for the new appointment call'}
          </DialogDescription>
        </DialogHeader>

        <div className="flex-1 overflow-y-auto p-6">
          <form id="call-modal-form" onSubmit={handleSubmit}>
            {/* Two Column Layout like reference image */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              
              {/* LEFT COLUMN: Source & Vehicle Details */}
              <div className="bg-white border border-gray-200 rounded-lg p-5 space-y-5">
                <h3 className="text-base font-semibold text-slate-900 border-b pb-3">Source & Vehicle Details</h3>
                
                {/* Priority Toggle */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Priority</Label>
                  <input type="hidden" name="priority" value={priority} />
                  <div className="flex rounded-lg overflow-hidden border border-gray-200">
                    {['High', 'Medium', 'Low'].map((p) => (
                      <button
                        key={p}
                        type="button"
                        onClick={() => setPriority(p)}
                        className={cn(
                          "flex-1 py-2.5 text-sm font-medium transition-colors",
                          priority === p 
                            ? "bg-slate-800 text-white" 
                            : "bg-white text-slate-600 hover:bg-gray-50"
                        )}
                      >
                        {p}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Source */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Source *</Label>
                  <SearchableDropdownSelect
                    name="appointmentSource"
                    options={appointmentSources}
                    defaultValue={editRecord?.appointmentSource || ''}
                    placeholder="Select source..."
                  />
                </div>

                {/* Year of Manufacture */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Year of Manufacture *</Label>
                  <Input name="yearOfManufacture" defaultValue={editRecord?.yearOfManufacture || ''} className="h-10 bg-gray-50" />
                </div>

                {/* Make */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Make *</Label>
                  <SearchableDropdownSelect
                    name="make"
                    options={makeOptions}
                    defaultValue={selectedMake}
                    placeholder="Select Make"
                    onValueChange={(val) => {
                        setSelectedMake(val);
                        setSelectedModel(''); // Reset model when make changes
                    }}
                  />
                </div>

                {/* Model */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Model *</Label>
                  <SearchableDropdownSelect
                    key={`model-${selectedMake}`} // Reset when make changes
                    name="model"
                    options={modelOptions}
                    defaultValue={selectedModel}
                    placeholder="Select Model"
                    onValueChange={(val) => setSelectedModel(val)}
                  />
                </div>

                {/* Variant */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Variant *</Label>
                  <SearchableDropdownSelect
                    key={`variant-${selectedModel}`} // Reset when model changes
                    name="variant"
                    options={variantOptions}
                    defaultValue={editRecord?.variant || ''}
                    placeholder="Select Variant"
                  />
                </div>

                {/* Odometer Reading */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Odometer Reading</Label>
                  <Input name="odometerReadingInKms" type="number" defaultValue={editRecord?.odometerReadingInKms || ''} className="h-10 bg-gray-50" />
                </div>

                {/* Ownership Serial Number */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Ownership Serial Number *</Label>
                  <Input name="ownershipSerialNumber" type="number" required defaultValue={editRecord?.ownershipSerialNumber || ''} className="h-10 bg-gray-50" />
                </div>
              </div>

              {/* RIGHT COLUMN: Booking Details */}
              <div className="bg-gray-50 border border-gray-200 rounded-lg p-5 space-y-5">
                <h3 className="text-base font-semibold text-slate-900 border-b pb-3">Booking Details</h3>
                
                {/* Vehicle Status (Hidden as per request) */}
                {/* <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Vehicle Status *</Label>
                  <SearchableDropdownSelect
                    name="inspectionStatus"
                    options={inspectionStatuses}
                    defaultValue={editRecord?.inspectionStatus || 'Pending'}
                    placeholder="Select status..."
                  />
                </div> */}

                {/* Customer Name */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Customer Name *</Label>
                  <Input name="ownerName" required defaultValue={editRecord?.ownerName || ''} className="h-10 bg-white" />
                </div>

                {/* Contact No */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Contact No. *</Label>
                  <Input name="customerContactNumber" type="tel" defaultValue={editRecord?.customerContactNumber || ''} className="h-10 bg-white" />
                </div>

                {/* Address for Inspection */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Address for Inspection *</Label>
                  <Input name="inspectionAddress" defaultValue={editRecord?.inspectionAddress || ''} className="h-10 bg-white" />
                </div>

                {/* Zip Code */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Zip Code *</Label>
                  <Input name="zipCode" defaultValue={editRecord?.zipCode || ''} className="h-10 bg-white" />
                </div>

                {/* Req. Date */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Req. Date *</Label>
                  <Input name="inspectionDateTime" type="date" defaultValue={editRecord?.inspectionDateTime ? new Date(editRecord.inspectionDateTime).toISOString().slice(0, 10) : ''} className="h-10 bg-white" />
                </div>

                {/* Remarks */}
                <div className="space-y-2">
                  <Label className="text-xs font-medium text-slate-600">Remarks</Label>
                  <Input name="remarks" defaultValue={editRecord?.remarks || ''} className="h-10 bg-white" />
                </div>
              </div>
            </div>

            {/* Hidden fields for required data not shown in 2-col layout */}
            <input type="hidden" name="appointmentId" value={editRecord?.appointmentId || 'Auto-generated'} />
            <input type="hidden" name="carRegistrationNumber" value={editRecord?.carRegistrationNumber || ''} />
            <input type="hidden" name="yearOfRegistration" value={editRecord?.yearOfRegistration || ''} />
            <input type="hidden" name="city" value={editRecord?.city || ''} />
            <input type="hidden" name="emailAddress" value={editRecord?.emailAddress || ''} />
            <input type="hidden" name="allocatedTo" value={editRecord?.allocatedTo || ''} />
            <input type="hidden" name="vehicleStatus" value={editRecord?.vehicleStatus || ''} />
            <input type="hidden" name="addedBy" value={addedBy} />
            <input type="hidden" name="ncdUcdName" value={editRecord?.ncdUcdName || ''} />
            <input type="hidden" name="repName" value={editRecord?.repName || ''} />
            <input type="hidden" name="repContact" value={editRecord?.repContact || ''} />
            <input type="hidden" name="bankSource" value={editRecord?.bankSource || ''} />
            <input type="hidden" name="referenceName" value={editRecord?.referenceName || ''} />
            <input type="hidden" name="inspectionEngineerNumber" value={engineerNumber} />
            <input type="hidden" name="additionalNotes" value={editRecord?.additionalNotes || ''} />

            {/* Images Section - Below the two columns */}
            {!editRecord && selectedFiles.length === 0 && (
              <div className="mt-6 border-2 border-dashed border-gray-200 rounded-lg p-6 text-center hover:bg-gray-50 transition-colors relative">
                <input type="file" multiple accept="image/*" onChange={handleFileChange} className="absolute inset-0 w-full h-full opacity-0 cursor-pointer" />
                <div className="flex flex-col items-center gap-2 text-slate-400">
                  <div className="p-3 bg-blue-50 text-blue-500 rounded-full"><Plus className="w-5 h-5" /></div>
                  <span className="text-sm font-medium text-slate-600">Click or drag images to upload (Max 5)</span>
                </div>
              </div>
            )}
            {selectedFiles.length > 0 && (
              <div className="mt-6 grid grid-cols-5 gap-3">
                {selectedFiles.map((file, index) => (
                  <div key={index} className="relative group aspect-square rounded-lg overflow-hidden border border-gray-200">
                    <Image 
                      src={URL.createObjectURL(file)} 
                      alt={`Preview ${index}`} 
                      fill 
                      className="object-cover" 
                    />
                    <button type="button" onClick={() => removeFile(index)} className="absolute top-1 right-1 p-1 bg-white/90 rounded-full shadow-sm opacity-0 group-hover:opacity-100 transition-opacity text-red-500"><X className="w-3 h-3" /></button>
                  </div>
                ))}
              </div>
            )}
          </form>
        </div>
        
        <DialogFooter className="px-6 py-4 border-t border-gray-200 bg-gray-50 shrink-0">
          <Button variant="outline" type="button" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="call-modal-form" className="bg-blue-600 hover:bg-blue-700 text-white">
            {editRecord ? 'Update Record' : 'Save Record'}
          </Button>
        </DialogFooter>

      </DialogContent>
    </Dialog>
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
  const [allCarVariances, setAllCarVariances] = useState<CarVarianceData[]>([]); // New state
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [columnConfig, setColumnConfig] = useState<{id: string; visible: boolean}[]>([]);
  const itemsPerPage = 100; // Increased default limit for better UX

  useEffect(() => {
    const loadConfig = async () => {
      let savedConfigs = null;

      try {
        const res = await fetch('/api/settings');
        if (res.ok) {
          const settings = await res.json();
          const targetSetting = settings.find((s: any) => s.key === 'telecalling_columns_config');
          if (targetSetting && targetSetting.value) {
            savedConfigs = typeof targetSetting.value === 'string' 
              ? JSON.parse(targetSetting.value) 
              : targetSetting.value;
            console.log('[Telecalling] Loaded column config from MongoDB');
          }
        }
      } catch (err) {
        console.warn('[Telecalling] MongoDB config load failed:', err);
      }

      if (!savedConfigs) {
        const saved = localStorage.getItem('telecalling_columns_config');
        if (saved) {
          try {
            savedConfigs = JSON.parse(saved);
            console.log('[Telecalling] Loaded column config from localStorage');
          } catch (err) {
            console.error('[Telecalling] Error parsing local storage:', err);
          }
        }
      }

      if (savedConfigs) {
        setColumnConfig(savedConfigs);
      }
    };

    loadConfig();
  }, []);

  // API Endpoints from environment variables
  const getBaseUrl = useCallback(() => process.env.NEXT_PUBLIC_BACKENDBASEURL || 'https://otobix-app-backend-development.onrender.com/api/', []);
  const getAddUrl = useCallback(() => `${getBaseUrl()}${process.env.NEXT_PUBLIC_TELECALLINGADD || 'inspection/telecallings/add'}`, [getBaseUrl]);
  const getUpdateUrl = useCallback(() => `${getBaseUrl()}${process.env.NEXT_PUBLIC_TELECALLINGUPDATE || 'inspection/telecallings/update'}`, [getBaseUrl]);
  const getDeleteUrl = useCallback(() => `${getBaseUrl()}${process.env.NEXT_PUBLIC_TELECALLINGDELETE || 'inspection/telecallings/delete'}`, [getBaseUrl]);
  
  const AUTH_TOKEN = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MDBhYzc2NTA4OGQxYTA2ODc3MDU0NCIsInVzZXJOYW1lIjoiY3VzdG9tZXIiLCJ1c2VyVHlwZSI6IkN1c3RvbWVyIiwiaWF0IjoxNzY0MzMxNjMxLCJleHAiOjIwNzk2OTE2MzF9.oXw1J4ca1XoIAg-vCO2y0QqZIq0VWHdYBrl2y9iIv4Q';

  // Ref for debounced save timeout
  const saveTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const fetchTelecallingData = useCallback(async (page = 1, limit = 100, search = '', status = 'All') => {
    setLoading(true);
    
    // Clear any existing telecalling cache to free up space
    if (typeof window !== 'undefined') {
      localStorage.removeItem('otobix_telecalling_cache');
    }

    try {
      const listUrl = `${getBaseUrl()}${process.env.NEXT_PUBLIC_TELECALLINGLIST || 'inspection/telecallings/get-list-by-telecaller'}`;
      const url = new URL(listUrl);
      url.searchParams.append('pageNumber', page.toString());
      url.searchParams.append('limit', limit.toString());
      if (search) url.searchParams.append('search', search);
      if (status !== 'All') url.searchParams.append('status', status);

      const teleRes = await fetch(url.toString(), {
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
      const total = teleData.totalCount || teleData.total || (Array.isArray(teleData) ? teleData.length : (teleData.data ? teleData.data.length : 0));
      
      setAllLeadCalls(calls);
      setTotalCount(total);
    } catch (error) {
      console.error('Failed to fetch telecalling data', error);
      setAllLeadCalls([]);
      setTotalCount(0);
    } finally {
      setLoading(false);
    }
  }, [getBaseUrl, AUTH_TOKEN]);

  const fetchAuxData = useCallback(async () => {
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

      // 2. Fetch fresh data from EXTERNAL backend APIs (not local MongoDB)
      const usersListUrl = `${getBaseUrl()}${process.env.NEXT_PUBLIC_USERSLIST || 'user/all-users-list'}`;
      const dropdownsUrl = `${getBaseUrl()}${process.env.NEXT_PUBLIC_CAR_DROPDOWNS_LIST || 'admin/customers/car-dropdowns/get-list'}?limit=20000`; // Fetch all for dropdowns

      const [usersRes, dropdownsRes] = await Promise.all([
        fetch(usersListUrl, {
          method: 'GET',
          headers: { 'Authorization': AUTH_TOKEN }
        }),
        fetch(dropdownsUrl, {
          method: 'GET',
          headers: { 'Authorization': AUTH_TOKEN }
        }),
      ]);

      // Process users
      let validUsers: UserOption[] = [];
      if (usersRes.ok) {
        const usersData = await usersRes.json();
        const usersList = Array.isArray(usersData) ? usersData : (usersData.data || []);
        validUsers = usersList.map((u: any) => ({
          _id: u._id || u.id,
          userName: u.userName || u.username || u.name || '',
          email: u.email || '',
          phoneNumber: u.phoneNumber || u.phone || '',
        }));
      }

      // Process dropdowns (contains both Appointment Source and Inspection Status)
      let validSources: DropdownOption[] = [];
      let validStatuses: DropdownOption[] = [];
      if (dropdownsRes.ok) {
        const dropdownsData = await dropdownsRes.json();
        const allDropdowns = Array.isArray(dropdownsData) ? dropdownsData : (dropdownsData.data || []);
        
        validSources = allDropdowns
          .filter((d: any) => d.type === 'Appointment Source' && d.isActive !== false)
          .map((d: any) => ({
            _id: d._id || d.id,
            description: d.description || d.name || '',
            type: d.type || 'Appointment Source',
            icon: d.icon,
            color: d.color,
            isActive: d.isActive !== false,
          }));

        validStatuses = allDropdowns
          .filter((d: any) => d.type === 'Inspection Status' && d.isActive !== false)
          .map((d: any) => ({
            _id: d._id || d.id,
            description: d.description || d.name || '',
            type: d.type || 'Inspection Status',
            icon: d.icon,
            color: d.color,
            isActive: d.isActive !== false,
          }));

        const validCarVariances = allDropdowns
          .filter((d: any) => d.make) // Assume items with 'make' are variances
          .map((d: any) => ({
             _id: d._id || d.id,
             make: d.make,
             model: d.model || d.carModel || '',
             variant: d.variant || ''
          }));
        setAllCarVariances(validCarVariances);
      }

      // If no dropdowns from API, use static defaults
      if (validSources.length === 0) {
        validSources = [
          { _id: '1', description: 'Website', type: 'Appointment Source', isActive: true },
          { _id: '2', description: 'Phone Call', type: 'Appointment Source', isActive: true },
          { _id: '3', description: 'Walk-in', type: 'Appointment Source', isActive: true },
          { _id: '4', description: 'Referral', type: 'Appointment Source', isActive: true },
        ];
      }

      if (validStatuses.length === 0) {
        validStatuses = [
          { _id: '1', description: 'Pending', type: 'Inspection Status', isActive: true, color: '#f59e0b' },
          { _id: '2', description: 'Scheduled', type: 'Inspection Status', isActive: true, color: '#3b82f6' },
          { _id: '3', description: 'Completed', type: 'Inspection Status', isActive: true, color: '#10b981' },
          { _id: '4', description: 'Cancelled', type: 'Inspection Status', isActive: true, color: '#ef4444' },
        ];
      }

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
       
       // Fallback to static defaults on error
       setAppointmentSources([
         { _id: '1', description: 'Website', type: 'Appointment Source', isActive: true },
         { _id: '2', description: 'Phone Call', type: 'Appointment Source', isActive: true },
         { _id: '3', description: 'Walk-in', type: 'Appointment Source', isActive: true },
       ]);
       setInspectionStatuses([
         { _id: '1', description: 'Pending', type: 'Inspection Status', isActive: true, color: '#f59e0b' },
         { _id: '2', description: 'Scheduled', type: 'Inspection Status', isActive: true, color: '#3b82f6' },
         { _id: '3', description: 'Completed', type: 'Inspection Status', isActive: true, color: '#10b981' },
         { _id: '4', description: 'Cancelled', type: 'Inspection Status', isActive: true, color: '#ef4444' },
       ]);
    }
  }, [getBaseUrl, AUTH_TOKEN]);

  useEffect(() => {
    fetchTelecallingData(currentPage, itemsPerPage, debouncedSearch, activeTab);
  }, [currentPage, activeTab, debouncedSearch, fetchTelecallingData]);

  useEffect(() => {
    fetchAuxData();
  }, [fetchAuxData]);

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
  const handleAddCall = async (newCall: Partial<TelecallingRecord>, files?: File[]) => {
    // Generate temporary ID for optimistic update
    const tempId = `temp-${Date.now()}`;
    const optimisticRecord = { 
        ...newCall, 
        _id: tempId,
        carImages: files ? files.map(f => URL.createObjectURL(f)) : [] // temporary preview
    } as TelecallingRecord;

    // Update UI immediately
    setAllLeadCalls((prev) => [optimisticRecord, ...prev]);
    setIsModalOpen(false);

    // Save to backend immediately
    try {
      const formData = new FormData();

      // Core fields
      formData.append('carRegistrationNumber', newCall.carRegistrationNumber || '');
      formData.append('ownerName', newCall.ownerName || '');
      formData.append('yearOfRegistration', newCall.yearOfRegistration || '');
      // Ensure ownershipSerialNumber is a number or string representation of it
      formData.append('ownershipSerialNumber', (newCall.ownershipSerialNumber || 0).toString());
      formData.append('make', newCall.make || '');
      formData.append('model', newCall.model || '');
      formData.append('variant', newCall.variant || '');
      
      // Optional defaults
      formData.append('inspectionStatus', newCall.inspectionStatus || 'Pending');
      formData.append('approvalStatus', newCall.approvalStatus || 'Pending');
      formData.append('priority', newCall.priority || 'Medium');
      formData.append('addedBy', newCall.addedBy || 'Telecaller');
      formData.append('createdBy', currentUser?.id || '');

      // Other fields (append if present)
      if (newCall.odometerReadingInKms) formData.append('odometerReadingInKms', newCall.odometerReadingInKms.toString());
      if (newCall.additionalNotes) formData.append('additionalNotes', newCall.additionalNotes);
      if (newCall.inspectionDateTime) formData.append('inspectionDateTime', newCall.inspectionDateTime);
      if (newCall.inspectionAddress) formData.append('inspectionAddress', newCall.inspectionAddress);
      if (newCall.customerContactNumber) formData.append('customerContactNumber', newCall.customerContactNumber);
      if (newCall.city) formData.append('city', newCall.city);
      if (newCall.emailAddress) formData.append('emailAddress', newCall.emailAddress);
      if (newCall.appointmentSource) formData.append('appointmentSource', newCall.appointmentSource);
      if (newCall.vehicleStatus) formData.append('vehicleStatus', newCall.vehicleStatus);
      if (newCall.zipCode) formData.append('zipCode', newCall.zipCode);
      if (newCall.yearOfManufacture) formData.append('yearOfManufacture', newCall.yearOfManufacture);
      if (newCall.allocatedTo) formData.append('allocatedTo', newCall.allocatedTo);
      if (newCall.ncdUcdName) formData.append('ncdUcdName', newCall.ncdUcdName);
      if (newCall.repName) formData.append('repName', newCall.repName);
      if (newCall.repContact) formData.append('repContact', newCall.repContact);
      if (newCall.bankSource) formData.append('bankSource', newCall.bankSource);
      if (newCall.referenceName) formData.append('referenceName', newCall.referenceName);
      if (newCall.remarks) formData.append('remarks', newCall.remarks);
      if (newCall.inspectionEngineerNumber) formData.append('inspectionEngineerNumber', newCall.inspectionEngineerNumber);
      
      // Handle Files
      if (files && files.length > 0) {
        files.forEach((file) => {
          formData.append('carImages', file);
        });
      }

      const res = await fetch(getAddUrl(), {
        method: 'POST',
        headers: {
            'Authorization': AUTH_TOKEN
            // Content-Type is intentionally omitted so browser sets it with boundary
        },
        body: formData,
      });

      if (res.ok) {
        const savedRecord = await res.json();
        // Replace temp record with actual saved record
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
  const handleEditCall = useCallback(async (updatedData: Partial<TelecallingRecord>) => {
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
  }, [editingRecord, currentUser, getUpdateUrl, AUTH_TOKEN]);

  // Optimistic Delete
  const handleDeleteCall = useCallback(async () => {
    if (!deletingRecord) return;
    const recordId = deletingRecord._id;
    const oldRecord = { ...deletingRecord };

    // Optimistic delete
    setAllLeadCalls(prev => prev.filter(r => r._id !== recordId));
    setIsDeleteModalOpen(false);

    try {
      const res = await fetch(getDeleteUrl(), {
        method: 'DELETE',
        headers: {
          'Authorization': AUTH_TOKEN,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ telecallingId: recordId })
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
  }, [deletingRecord, getDeleteUrl, AUTH_TOKEN]);

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
    const preferredOrder = ['Scheduled', 'Pending', 'Completed', 'Cancelled'];
    
    allLeadCalls.forEach((call) => {
      let status = call.inspectionStatus || 'Pending';
      
      // Normalize status: check against preferred order first
      const preferred = preferredOrder.find(
        p => p.toLowerCase() === status.toLowerCase()
      );
      
      if (preferred) {
        status = preferred;
      } else {
        // Fallback: capitalize first letter, rest lowercase (e.g., RUNNING -> Running)
        status = status.charAt(0).toUpperCase() + status.slice(1).toLowerCase();
      }
      
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

      const matchesTab = activeTab === 'All' || 
        (call.inspectionStatus || 'Pending').toLowerCase() === activeTab.toLowerCase();

      return matchesSearch && matchesTab;
    });

    const isServerSide = totalCount > allLeadCalls.length;
    const total = isServerSide ? totalCount : filtered.length;
    const start = (currentPage - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    // If server side paginated, allLeadCalls is already sliced
    const sliced = isServerSide ? filtered : filtered.slice(start, end);

    return {
      currentCalls: sliced,
      pagination: {
        currentPage,
        totalItems: total,
        totalPages: Math.ceil(total / itemsPerPage),
        startIndex: start,
        endIndex: Math.min(start + sliced.length, total),
        onNext: () => setCurrentPage((p) => p + 1),
        onPrev: () => setCurrentPage((p) => p - 1),
        onSetPage: (p: number) => setCurrentPage(p),
        canNext: currentPage < Math.ceil(total / itemsPerPage),
        canPrev: currentPage > 1,
      },
    };
  }, [allLeadCalls, debouncedSearch, activeTab, currentPage, itemsPerPage, totalCount]);

  // Table Columns - Map of all available columns with IDs
  const columnDefinitions: Record<string, any> = useMemo(() => ({
    appointmentId: {
      header: 'Appt ID',
      accessor: 'appointmentId' as keyof TelecallingRecord,
      className: 'font-mono text-xs whitespace-nowrap',
      width: 'auto',
    },
    carRegistrationNumber: {
      header: 'Reg. No',
      accessor: 'carRegistrationNumber' as keyof TelecallingRecord,
      className: 'font-bold whitespace-nowrap',
      width: 'auto',
    },
    ownerName: {
      header: 'Owner',
      accessor: 'ownerName' as keyof TelecallingRecord,
      className: 'font-semibold whitespace-nowrap',
      width: 'auto',
    },
    city: {
      header: 'City',
      accessor: 'city' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    allocatedTo: {
      header: 'Allocated To',
      render: (row: TelecallingRecord) => {
        const user = users.find(
          (u) => u.email === row.allocatedTo || u.userName === row.allocatedTo
        );
        return (
          <span className="whitespace-nowrap">
            {user?.userName || row.allocatedTo || '-'}
          </span>
        );
      },
      width: 'auto',
    },
    inspectionStatus: {
      header: 'Status',
      render: (row: TelecallingRecord) => (
        <StatusBadge
          status={row.inspectionStatus || 'Pending'}
          dropdownOptions={inspectionStatuses}
        />
      ),
      width: 'auto',
    },
    inspectionDateTime: {
      header: 'Inspection Date',
      render: (row: TelecallingRecord) => row.inspectionDateTime ? new Date(row.inspectionDateTime).toLocaleDateString() : '-',
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    priority: {
      header: 'Priority',
      render: (row: TelecallingRecord) => <PriorityBadge priority={row.priority || 'Medium'} />,
      width: 'auto',
    },
    make: {
      header: 'Make',
      accessor: 'make' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    model: {
      header: 'Model',
      accessor: 'model' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    variant: {
      header: 'Variant',
      accessor: 'variant' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    customerContactNumber: {
      header: 'Contact',
      accessor: 'customerContactNumber' as keyof TelecallingRecord,
      className: 'font-mono text-xs whitespace-nowrap',
      width: 'auto',
    },
    appointmentSource: {
      header: 'Source',
      render: (row: TelecallingRecord) => {
        const source = row.appointmentSource;
        if (!source) return <span className="text-xs">-</span>;

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

        return <span className="text-xs whitespace-nowrap">{source}</span>;
      },
      width: 'auto',
    },
    remarks: {
      header: 'Remarks',
      accessor: 'remarks' as keyof TelecallingRecord,
      className: 'text-xs whitespace-normal min-w-[250px]',
      width: 'auto',
    },
    createdBy: {
      header: 'Created By',
      render: (row: TelecallingRecord) => {
        const user = users.find(
          (u) =>
            u._id === row.createdBy ||
            u.email === row.createdBy ||
            u.userName === row.createdBy
        );
        return (
          <span className="text-xs whitespace-nowrap">
            {user?.userName || row.createdBy || '-'}
          </span>
        );
      },
      width: 'auto',
    },
    createdAt: {
      header: 'Created At',
      render: (row: TelecallingRecord) =>
        row.createdAt ? new Date(row.createdAt).toLocaleDateString() : '-',
      className: 'text-xs whitespace-nowrap',
      width: 'auto',
    },
    yearOfRegistration: {
      header: 'Reg. Year',
      accessor: 'yearOfRegistration' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    ownershipSerialNumber: {
      header: 'Ownership Serial',
      accessor: 'ownershipSerialNumber' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    yearOfManufacture: {
      header: 'Mfg Year',
      accessor: 'yearOfManufacture' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    odometerReadingInKms: {
      header: 'Odometer',
      render: (row: TelecallingRecord) => row.odometerReadingInKms ? `${row.odometerReadingInKms.toLocaleString()} km` : '-',
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    emailAddress: {
      header: 'Telecaller',
      accessor: 'emailAddress' as keyof TelecallingRecord,
      className: 'text-xs whitespace-nowrap',
      width: 'auto',
    },
    zipCode: {
      header: 'Zip Code',
      accessor: 'zipCode' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    inspectionAddress: {
      header: 'Inspection Address',
      accessor: 'inspectionAddress' as keyof TelecallingRecord,
      className: 'text-xs whitespace-normal min-w-[200px]',
      width: 'auto',
    },
    vehicleStatus: {
      header: 'Vehicle Status',
      accessor: 'vehicleStatus' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    ncdUcdName: {
      header: 'NCD/UCD Name',
      accessor: 'ncdUcdName' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    repName: {
      header: 'Rep Name',
      accessor: 'repName' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    repContact: {
      header: 'Rep Contact',
      accessor: 'repContact' as keyof TelecallingRecord,
      className: 'font-mono text-xs whitespace-nowrap',
      width: 'auto',
    },
    bankSource: {
      header: 'Bank Source',
      accessor: 'bankSource' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    referenceName: {
      header: 'Reference Name',
      accessor: 'referenceName' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    addedBy: {
      header: 'Added By',
      accessor: 'addedBy' as keyof TelecallingRecord,
      className: 'whitespace-nowrap',
      width: 'auto',
    },
    additionalNotes: {
      header: 'Additional Notes',
      accessor: 'additionalNotes' as keyof TelecallingRecord,
      className: 'text-xs whitespace-normal min-w-[200px]',
      width: 'auto',
    },
  }), [users, inspectionStatuses, appointmentSources]);



  // Build columns array based on saved config or defaults
  const columns = useMemo(() => {
    // Actions column is always last
    const actionsColumn = {
      header: 'Actions',
      align: 'right' as const,
      render: (row: TelecallingRecord) => (
        <div className="flex items-center justify-end gap-1">
          <button
            onClick={(e) => {
              e.stopPropagation();
              openEditModal(row);
            }}
            className="text-slate-500 hover:text-blue-500 transition-colors p-1.5 hover:bg-blue-50 rounded"
            title="Edit"
          >
            <Edit2 className="w-3.5 h-3.5" />
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation();
              openDeleteModal(row);
            }}
            className="text-slate-500 hover:text-red-500 transition-colors p-1.5 hover:bg-red-50 rounded"
            title="Delete"
          >
            <Trash2 className="w-3.5 h-3.5" />
          </button>
        </div>
      ),
      width: '80px',
    };

    // If config exists, use it to filter and order columns
    if (columnConfig.length > 0) {
      console.log('[Telecalling] Building columns from config. Visible items:', columnConfig.filter(c => c.visible).length);
      const visibleCols = columnConfig
        .filter(c => c.visible)
        .map(c => {
          const def = columnDefinitions[c.id];
          if (!def) console.warn('[Telecalling] No definition found for column:', c.id);
          return def;
        })
        .filter(Boolean);
      return [...visibleCols, actionsColumn];
    }

    // Default column order if no config saved
    const defaultColumnOrder = [
      'appointmentId', 'carRegistrationNumber', 'ownerName', 'city', 'allocatedTo',
      'inspectionStatus', 'inspectionDateTime', 'priority', 'make', 'model',
      'variant', 'customerContactNumber', 'appointmentSource', 'remarks', 'createdBy', 'createdAt'
    ];

    console.log('[Telecalling] Building columns from defaults');
    // Default: show all columns in order
    const defaultCols = defaultColumnOrder
      .map(id => columnDefinitions[id])
      .filter(Boolean);
    return [...defaultCols, actionsColumn];
  }, [columnConfig, columnDefinitions]);

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
            key={editingRecord?._id || 'new'}
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
        carVariances={allCarVariances}
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
        </>
      )}
    </div>
  );
}
