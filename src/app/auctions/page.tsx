'use client';

import { useState, useEffect, useMemo } from 'react';
import { useSession } from 'next-auth/react';
import { useHeader } from '@/context/HeaderContext';
import Table from '@/components/Table';
import { 
  Search, 
  Download, 
  Car, 
  Calendar, 
  Clock, 
  Gavel, 
  ChevronRight,
  MapPin,
  TrendingUp,
  X,
  User,
  Phone,
  Info,
  BadgeCheck,
  Fuel,
  Settings,
  LayoutGrid,
  Armchair,
  FileText,
  ArrowUp,
  Activity,
  Shield,
} from 'lucide-react';

// --- Types ---

interface AuctionRecord {
  id: string;
  _id?: string;
  make: string;
  model: string;
  variant: string;
  yearOfRegistration: string;
  odometerReadingInKms: number;
  carRegistrationNumber: string;
  ownershipSerialNumber: number;
  auctionStatus: string;
  imageUrl?: string;
  carImages?: string[];
  highestBid?: number;
  totalBids?: number;
  remainingTime?: string;
  endTime?: string;
  auctionEndTime?: string;
  upcomingUntil?: string;
  basePrice?: number;
  location?: string;
  [key: string]: any;
}

const CountdownTimer = ({ endTime }: { endTime: string | undefined }) => {
  const [timeLeft, setTimeLeft] = useState<string>('00:00:00');

  useEffect(() => {
    // eslint-disable-next-line react-hooks/exhaustive-deps
    if (!endTime) {
      setTimeLeft('00:00:00');
      return;
    }

    const calculateTime = () => {
      try {
        const now = new Date().getTime();
        const endData = new Date(endTime);
        
        // Handle invalid date
        if (isNaN(endData.getTime())) {
          setTimeLeft('00:00:00');
          return;
        }

        const end = endData.getTime();
        const diff = end - now;

        if (diff <= 0) {
          setTimeLeft('00:00:00');
          return;
        }

        const hours = Math.floor(diff / (1000 * 60 * 60));
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((diff % (1000 * 60)) / 1000);

        setTimeLeft(
          `${hours.toString().padStart(2, '0')}:${minutes
            .toString()
            .padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
        );
      } catch (e) {
        setTimeLeft('00:00:00');
      }
    };

    calculateTime();
    const interval = setInterval(calculateTime, 1000);
    return () => clearInterval(interval);
  }, [endTime]);

  return <span>{timeLeft}</span>;
};

const CarDetailsModal = ({ 
  carId, 
  isOpen, 
  onClose,
  authToken 
}: { 
  carId: string | null; 
  isOpen: boolean; 
  onClose: () => void;
  authToken: string | null;
}) => {
  const [details, setDetails] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [activeImage, setActiveImage] = useState(0);
  const [activeTab, setActiveTab] = useState('overview');

  const backendBaseUrl = process.env.NEXT_PUBLIC_BACKENDBASEURL;
  const detailsPath = process.env.NEXT_PUBLIC_CAR_DETAILS || 'car/details';

  const fetchDetails = async () => {
    setIsLoading(true);
    try {
      const url = `${backendBaseUrl}${detailsPath}/${carId}`;
      const res = await fetch(url, {
        headers: { 'Authorization': `Bearer ${authToken}` }
      });
      if (res.ok) {
        const data = await res.json();
        const rawDetails = data.data || data;

        // Construct a normalized images array
        const images: string[] = [];
        
        // Helper to push valid images
        const addImages = (source: any) => {
             if (Array.isArray(source)) {
                 source.forEach(img => typeof img === 'string' && img.length > 5 && images.push(img));
             } else if (typeof source === 'string' && source.length > 5) {
                 images.push(source);
             }
        };

        // Priority order for images
        addImages(rawDetails.carImages);
        addImages(rawDetails.frontMain);
        addImages(rawDetails.frontMainImages);
        addImages(rawDetails.rearMain);
        addImages(rawDetails.rearMainImages);
        addImages(rawDetails.leftSide);
        addImages(rawDetails.leftSideImages);
        addImages(rawDetails.rightSide);
        addImages(rawDetails.rightSideImages);
        addImages(rawDetails.interior);
        addImages(rawDetails.interiorImages);
        addImages(rawDetails.bonnet); 
        addImages(rawDetails.bonnetImages);
        addImages(rawDetails.boot);
        addImages(rawDetails.bootImages);
        
        // Fallback or single image
        if (images.length === 0 && rawDetails.imageUrl) {
            images.push(rawDetails.imageUrl);
        }

        setDetails({ ...rawDetails, carImages: images.length > 0 ? images : null });
      }
    } catch (error) {
      console.error('Fetch details error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (isOpen && carId && authToken) {
      fetchDetails();
    } else {
      setDetails(null);
      setActiveImage(0);
      setActiveTab('overview');
    }
     // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isOpen, carId, authToken]);


  if (!isOpen) return null;

  const tabs = [
    { id: 'overview', label: 'Overview', icon: LayoutGrid },
    { id: 'exterior', label: 'Exterior', icon: Car },
    { id: 'interior', label: 'Interior', icon: Armchair },
    { id: 'engine', label: 'Engine & Chassis', icon: Settings },
    { id: 'docs', label: 'Documents', icon: FileText },
  ];

  // Helper to safely display dropdown lists or single values
  const displayValue = (val: any) => {
      if (Array.isArray(val)) return val.join(', ');
      return val || '-';
  };

  // Helper for status badges
  const StatusBadge = ({ value, type = 'neutral' }: { value: string, type?: 'success' | 'warning' | 'error' | 'neutral' | 'info' }) => {
      if (!value) return <span className="text-slate-300">-</span>;
      
      const styles = {
          success: 'bg-emerald-50 text-emerald-700 border-emerald-100',
          warning: 'bg-amber-50 text-amber-700 border-amber-100',
          error: 'bg-red-50 text-red-700 border-red-100',
          neutral: 'bg-slate-50 text-slate-600 border-slate-100',
          info: 'bg-blue-50 text-blue-700 border-blue-100'
      };

      // Auto-detect type for common values if generic
      let detectedType = type;
      const lower = value.toLowerCase();
      if (['ok', 'original', 'good', 'available', 'yes'].some(k => lower.includes(k))) detectedType = 'success';
      if (['repaired', 'dent', 'scratch', 'faded', 'crack', 'torn', 'worn'].some(k => lower.includes(k))) detectedType = 'warning';
      if (['replace', 'missing', 'damaged', 'major', 'no'].some(k => lower.includes(k))) detectedType = 'error';

      return (
          <span className={`px-2 py-0.5 rounded text-[10px] uppercase font-bold border ${styles[detectedType]} tracking-wide`}>
              {value}
          </span>
      );
  };

  const SectionTitle = ({ icon: Icon, title }: { icon: any, title: string }) => (
      <div className="flex items-center gap-2 mb-4 pb-2 border-b border-slate-100">
          <div className="p-1.5 bg-blue-50 rounded-lg">
            <Icon className="w-4 h-4 text-blue-600" />
          </div>
          <h4 className="text-sm font-black text-slate-800 uppercase tracking-widest">{title}</h4>
      </div>
  );

  const GridItem = ({ label, value, highlight = false }: { label: string, value: any, highlight?: boolean }) => (
    <div className={`flex flex-col gap-1 p-3 rounded-xl transition-all ${highlight ? 'bg-slate-50' : 'hover:bg-slate-50/50'}`}>
        <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">{label}</span>
        <span className={`text-xs font-bold ${highlight ? 'text-slate-900' : 'text-slate-700'} break-words`}>
           {typeof value === 'object' && !Array.isArray(value) && value !== null ? '-' : displayValue(value)}
        </span>
    </div>
  );

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-slate-900/80 backdrop-blur-md transition-all duration-300">
      <div className="bg-white w-full max-w-7xl h-[90vh] rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in duration-300 border border-white/20">
        
        {/* Header */}
        <div className="flex items-center justify-between px-8 py-5 border-b border-slate-100 bg-white z-20">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 bg-blue-600 rounded-2xl flex items-center justify-center shadow-lg shadow-blue-600/20 text-white">
              <Car className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-xl font-black text-slate-900 leading-none mb-1">
                {isLoading ? 'Loading...' : `${details?.make || ''} ${details?.model || ''}`}
              </h3>
              {!isLoading && (
                <div className="flex items-center gap-2 text-xs font-medium text-slate-500">
                  <span className="bg-slate-100 px-2 py-0.5 rounded text-slate-700 font-bold tracking-wide">{details?.variant}</span>
                  <span>&bull;</span>
                  <span className="font-mono bg-slate-100 px-2 py-0.5 rounded text-slate-700 font-bold">{details?.carRegistrationNumber}</span>
                  <span>&bull;</span>
                  <span>{details?.ownershipSerialNumber || 1}st Owner</span>
                </div>
              )}
            </div>
          </div>
          <button 
            onClick={onClose} 
            className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-slate-100 text-slate-400 hover:text-rose-500 transition-all active:scale-95"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="flex flex-1 overflow-hidden">
          {/* Sidebar Tabs */}
          <div className="w-64 bg-slate-50 border-r border-slate-200 flex flex-col py-6 gap-2 px-4 shrink-0 overflow-y-auto">
             {tabs.map(tab => (
                 <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`flex items-center gap-3 px-4 py-3 rounded-xl text-xs font-bold transition-all duration-200 ${
                        activeTab === tab.id 
                        ? 'bg-blue-600 text-white shadow-lg shadow-blue-600/20 translate-x-1' 
                        : 'text-slate-500 hover:bg-white hover:text-blue-600 hover:shadow-sm'
                    }`}
                 >
                    <tab.icon className="w-4 h-4" />
                    {tab.label}
                 </button>
             ))}
             
             <div className="mt-auto px-4 pt-6 border-t border-slate-200">
                <div className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-3">Quick Actions</div>
                <button className="w-full flex items-center gap-2 justify-center py-2.5 bg-white border border-slate-200 rounded-xl text-xs font-bold text-slate-700 hover:border-blue-300 hover:text-blue-600 shadow-sm transition-all mb-2">
                   <Download className="w-4 h-4" /> Inspection PDF
                </button>
             </div>
          </div>

          {/* Main Content Area */}
          <div className="flex-1 overflow-auto custom-scrollbar p-8 bg-white/50 relative">
             {isLoading ? (
               <div className="absolute inset-0 flex flex-col items-center justify-center bg-white/80 z-10">
                  <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mb-4" />
                  <p className="text-slate-500 font-bold text-sm tracking-widest uppercase animate-pulse">Retrieving Data...</p>
               </div>
             ) : details && (
                <div className="max-w-5xl mx-auto space-y-8 pb-12">
                   
                   {/* Overview Tab */}
                   {activeTab === 'overview' && (
                       <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
                           {/* Gallery & Pricing */}
                           <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                               <div className="lg:col-span-2 space-y-4">
                                   <div className="aspect-video bg-slate-100 rounded-2xl overflow-hidden shadow-sm relative group">
                                       <img 
                                         src={details.carImages?.[activeImage] || details.imageUrl || details.frontMainImages?.[0] || '/placeholder-car.png'} 
                                         alt="Car Main" 
                                         className="w-full h-full object-cover"
                                       />
                                       <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity flex items-end justify-center pb-4">
                                          <div className="flex gap-2 p-2 bg-black/40 backdrop-blur rounded-full">
                                            {details.carImages?.map((_: any, idx: number) => (
                                                <button 
                                                  key={idx} 
                                                  onClick={(e) => { e.stopPropagation(); setActiveImage(idx); }}
                                                  className={`w-2 h-2 rounded-full transition-all ${activeImage === idx ? 'bg-white scale-125' : 'bg-white/40 hover:bg-white/80'}`} 
                                                />
                                            ))}
                                          </div>
                                       </div>
                                       <div className="absolute top-4 right-4 bg-white/90 backdrop-blur px-3 py-1 rounded-lg text-[10px] font-bold shadow-sm">
                                          {activeImage + 1} / {details.carImages?.length || 1}
                                       </div>
                                   </div>
                               </div>
                               <div className="space-y-4">
                                   <div className="bg-gradient-to-br from-blue-600 to-blue-700 rounded-2xl p-6 text-white shadow-xl shadow-blue-600/20">
                                       <p className="text-blue-100 text-xs font-bold uppercase tracking-widest mb-1">Highest Bid</p>
                                       <div className="text-3xl font-black mb-4">₹{(details.highestBid || 0).toLocaleString()}</div>
                                       <div className="flex items-center gap-2 text-blue-100 text-xs font-medium bg-white/10 p-2 rounded-lg">
                                          <Gavel className="w-3 h-3" />
                                          <span>{details.totalBids || 0} active bids</span>
                                       </div>
                                   </div>
                                   <div className="bg-white rounded-2xl p-6 border border-slate-100 shadow-sm space-y-4">
                                       <div>
                                           <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest mb-1">Base Price</p>
                                           <div className="text-xl font-bold text-slate-800">₹{(details.priceDiscovery || details.basePrice || 0).toLocaleString()}</div>
                                       </div>
                                       <div>
                                           <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest mb-1">Customer Expectation</p>
                                           <div className="text-xl font-bold text-slate-800">₹{(details.customerExpectedPrice || 0).toLocaleString()}</div>
                                       </div>
                                       <div className="pt-4 border-t border-slate-100">
                                            <div className="flex items-center gap-3">
                                                <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center">
                                                    <User className="w-5 h-5 text-slate-400" />
                                                </div>
                                                <div>
                                                    <div className="text-xs font-bold text-slate-900">{details.ownerName || 'Unknown'}</div>
                                                    <div className="text-[10px] font-medium text-slate-500">{details.location || details.city}</div>
                                                </div>
                                            </div>
                                       </div>
                                   </div>
                               </div>
                           </div>

                           {/* Spec Grid */}
                           <div>
                               <SectionTitle icon={Info} title="Key Specifications" />
                               <div className="grid grid-cols-2md:grid-cols-4 gap-4">
                                   <GridItem label="Make / Model" value={`${details.make} ${details.model}`} highlight />
                                   <GridItem label="Variant" value={details.variant} highlight />
                                   <GridItem label="Reg. Year" value={details.yearOfRegistration} />
                                   <GridItem label="Kms Driven" value={`${(details.odometerReadingInKms || 0).toLocaleString()} km`} />
                                   <GridItem label="Fuel Type" value={details.fuelType} />
                                   <GridItem label="Transmission" value={details.transmission || details.transmissionTypeDropdownList?.[0]} />
                                   <GridItem label="Ownership" value={details.ownershipSerialNumber} />
                                   <GridItem label="RTO" value={details.registeredRto} />
                                   <GridItem label="Insurance" value={details.insurance} />
                                   <GridItem label="Color" value={details.exteriorColor || details.color} />
                                   <GridItem label="Mfg Date" value={details.yearMonthOfManufacture ? new Date(details.yearMonthOfManufacture).toLocaleDateString(undefined, {month:'short', year:'numeric'}) : '-'} />
                                   <GridItem label="Status" value={<StatusBadge value={details.auctionStatus || details.status} type="info" />} />
                               </div>
                           </div>
                       </div>
                   )}

                   {/* Exterior Tab */}
                   {activeTab === 'exterior' && (
                       <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
                           <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                               <div>
                                   <SectionTitle icon={Car} title="Panels & Structure" />
                                   <div className="grid grid-cols-2 gap-3">
                                       <GridItem label="Bonnet" value={<StatusBadge value={details.bonnet} />} />
                                       <GridItem label="Roof" value={<StatusBadge value={details.roof} />} />
                                       <GridItem label="Front Bumper" value={<StatusBadge value={details.frontBumper} />} />
                                       <GridItem label="Rear Bumper" value={<StatusBadge value={details.rearBumper} />} />
                                       <GridItem label="Boot Door" value={<StatusBadge value={details.bootDoor} />} />
                                       <GridItem label="Dickey Floor" value={<StatusBadge value={details.bootFloor} />} />
                                       <GridItem label="Cowl Top" value={<StatusBadge value={details.cowlTop} />} />
                                       <GridItem label="Firewall" value={<StatusBadge value={details.firewall} />} />
                                   </div>
                               </div>
                               <div>
                                   <SectionTitle icon={ArrowUp} title="Sides & Glass" />
                                    <div className="grid grid-cols-2 gap-3">
                                       <GridItem label="LHS Front Door" value={<StatusBadge value={details.lhsFrontDoor} />} />
                                       <GridItem label="RHS Front Door" value={<StatusBadge value={details.rhsFrontDoor} />} />
                                       <GridItem label="LHS Rear Door" value={<StatusBadge value={details.lhsRearDoor} />} />
                                       <GridItem label="RHS Rear Door" value={<StatusBadge value={details.rhsRearDoor} />} />
                                       <GridItem label="Front Windshield" value={<StatusBadge value={details.frontWindshield} />} />
                                       <GridItem label="Rear Windshield" value={<StatusBadge value={details.rearWindshield} />} />
                                       <GridItem label="LHS Fender" value={<StatusBadge value={details.lhsFender} />} />
                                       <GridItem label="RHS Fender" value={<StatusBadge value={details.rhsFender} />} />
                                   </div>
                               </div>
                           </div>
                           
                           <div>
                               <SectionTitle icon={Activity} title="Lighting & Tyres" />
                               <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                   <GridItem label="LHS Headlamp" value={<StatusBadge value={details.lhsHeadlamp} />} />
                                   <GridItem label="RHS Headlamp" value={<StatusBadge value={details.rhsHeadlamp} />} />
                                   <GridItem label="LHS Tail Lamp" value={<StatusBadge value={details.lhsTailLamp} />} />
                                   <GridItem label="RHS Tail Lamp" value={<StatusBadge value={details.rhsTailLamp} />} />
                                   <GridItem label="LHS Front Tyre" value={<StatusBadge value={details.lhsFrontTyre} />} />
                                   <GridItem label="RHS Front Tyre" value={<StatusBadge value={details.rhsFrontTyre} />} />
                                   <GridItem label="LHS Rear Tyre" value={<StatusBadge value={details.lhsRearTyre} />} />
                                   <GridItem label="RHS Rear Tyre" value={<StatusBadge value={details.rhsRearTyre} />} />
                               </div>
                           </div>
                           
                           {details.comments && (
                               <div className="bg-slate-50 border border-slate-200 p-4 rounded-xl">
                                   <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-2">Exterior Comments</p>
                                   <p className="text-sm font-medium text-slate-700">{details.comments}</p>
                               </div>
                           )}
                       </div>
                   )}

                   {/* Interior Tab */}
                   {activeTab === 'interior' && (
                       <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
                           <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                               <GridItem label="Odometer" value={details.odometerReadingInKms} highlight />
                               <GridItem label="AC Cooling" value={details.acCoolingDropdownList || details.airConditioningClimateControl} />
                               <GridItem label="Heater" value={details.airConditioningManual} />
                               <GridItem label="Music System" value={details.musicSystem} />
                               <GridItem label="Power Windows" value={details.noOfPowerWindows} />
                               <GridItem label="Leather Seats" value={details.leatherSeats} />
                               <GridItem label="Sunroof" value={details.sunroof} />
                               <GridItem label="Steering Audio" value={details.steeringMountedAudioControl} />
                               <GridItem label="Reverse Camera" value={details.reverseCamera} />
                           </div>

                           <div>
                               <SectionTitle icon={Shield} title="Safety & Airbags" />
                               <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                   <GridItem label="Airbags Count" value={details.noOfAirBags} highlight />
                                   <GridItem label="ABS" value={details.abs} />
                                   <GridItem label="Driver Airbag" value={details.driverAirbag} />
                                   <GridItem label="Co-Driver Airbag" value={details.coDriverAirbag} />
                               </div>
                           </div>

                           {details.commentOnInterior && (
                               <div className="bg-slate-50 border border-slate-200 p-4 rounded-xl">
                                   <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-2">Interior Comments</p>
                                   <p className="text-sm font-medium text-slate-700">{details.commentOnInterior}</p>
                               </div>
                           )}
                       </div>
                   )}

                   {/* Engine & Chassis Tab */}
                   {activeTab === 'engine' && (
                       <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
                           <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                               <GridItem label="Engine" value={<StatusBadge value={details.engine} />} />
                               <GridItem label="Battery" value={<StatusBadge value={details.battery} />} />
                               <GridItem label="Suspension" value={<StatusBadge value={details.suspension} />} />
                               <GridItem label="Clutch" value={<StatusBadge value={details.clutch} />} />
                               <GridItem label="Gear Shift" value={<StatusBadge value={details.gearShift} />} />
                               <GridItem label="Brakes" value={<StatusBadge value={details.brakes} />} />
                               <GridItem label="Steering" value={<StatusBadge value={details.steering} />} />
                               <GridItem label="Engine Oil" value={<StatusBadge value={details.engineOil} />} />
                               <GridItem label="Coolant" value={<StatusBadge value={details.coolant} />} />
                               <GridItem label="Exhaust Smoke" value={<StatusBadge value={details.exhaustSmoke} />} />
                               <GridItem label="Engine Mount" value={<StatusBadge value={details.engineMount} />} />
                               <GridItem label="Blow By" value={<StatusBadge value={details.enginePermisableBlowBy} />} />
                           </div>

                           <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                               {details.commentsOnEngine && (
                                   <div className="bg-slate-50 border border-slate-200 p-4 rounded-xl">
                                      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-2">Engine Comments</p>
                                      <p className="text-sm font-medium text-slate-700">{details.commentsOnEngine}</p>
                                   </div>
                               )}
                               {details.commentsOnTransmission && (
                                   <div className="bg-slate-50 border border-slate-200 p-4 rounded-xl">
                                      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-2">Transmission Comments</p>
                                      <p className="text-sm font-medium text-slate-700">{details.commentsOnTransmission}</p>
                                   </div>
                               )}
                           </div>
                       </div>
                   )}

                   {/* Documents Tab */}
                   {activeTab === 'docs' && (
                       <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
                           <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                               <GridItem label="RC Availability" value={details.rcBookAvailability} highlight />
                               <GridItem label="RC Condition" value={details.rcCondition} />
                               <GridItem label="Registration Type" value={details.registrationType} />
                               <GridItem label="Mismatch in RC" value={details.mismatchInRc} />
                               <GridItem label="Duplicate Key" value={details.duplicateKey} />
                               <GridItem label="Part Peshi" value={details.partyPeshi} />
                               <GridItem label="RTO NOC" value={details.rtoNoc} />
                               <GridItem label="Hypothecation" value={details.hypothecationDetails} />
                               <GridItem label="Chassis Number" value={details.chassisNumber} />
                               <GridItem label="Engine Number" value={details.engineNumber} />
                           </div>

                           <div>
                               <SectionTitle icon={FileText} title="Tax & Insurance" />
                               <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                   <GridItem label="Road Tax Validity" value={details.roadTaxValidity} />
                                   <GridItem label="Tax Valid Till" value={details.taxValidTill ? new Date(details.taxValidTill).toLocaleDateString() : '-'} />
                                   <GridItem label="Insurance Type" value={details.insurance} />
                                   <GridItem label="Insurance Validity" value={details.insuranceValidity ? new Date(details.insuranceValidity).toLocaleDateString() : '-'} />
                                   <GridItem label="No Claim Bonus" value={details.noClaimBonus} />
                                   <GridItem label="Policy Number" value={details.insurancePolicyNumber || details.policyNumber} />
                               </div>
                           </div>
                       </div>
                   )}

                </div>
             )}
          </div>
        </div>
      </div>
    </div>
  );
};

const AUCTION_STATUSES = [
  { id: 'upcoming', label: 'Upcoming', color: 'text-amber-600', bg: 'bg-amber-50', borderColor: 'border-amber-200' },
  { id: 'live', label: 'Live', color: 'text-red-600', bg: 'bg-red-50', borderColor: 'border-red-200' },
  { id: 'otobuy', label: 'Otobuy', color: 'text-blue-600', bg: 'bg-blue-50', borderColor: 'border-blue-200' },
  { id: 'liveAuctionEnded', label: 'Ended', color: 'text-gray-600', bg: 'bg-gray-50', borderColor: 'border-gray-200' },
  { id: 'sold', label: 'Sold', color: 'text-emerald-600', bg: 'bg-emerald-50', borderColor: 'border-emerald-200' },
  { id: 'removed', label: 'Removed', color: 'text-slate-400', bg: 'bg-slate-50', borderColor: 'border-slate-200' },
];

export default function AuctionsPage() {
  const { data: session } = useSession();
  const { setTitle, setSearchContent, setActionsContent } = useHeader();
  
  const [activeTab, setActiveTab] = useState<string>('live');
  const [cars, setCars] = useState<AuctionRecord[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  // Car Details Modal State
  const [selectedCarId, setSelectedCarId] = useState<string | null>(null);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);

  const backendBaseUrl = process.env.NEXT_PUBLIC_BACKENDBASEURL;
  const carsListPath = process.env.NEXT_PUBLIC_CARS_LIST;
  const authToken = (session?.user as any)?.backendToken;

  const fetchCars = async (status: string) => {
    if (!backendBaseUrl || !carsListPath) {
        console.error('Missing API configuration in .env.local');
        return;
    }
    
    setIsLoading(true);
    console.log(`Fetching ${status} cars...`);
    
    try {
      const url = `${backendBaseUrl}${carsListPath}?auctionStatus=${status}`;
      console.log('Request URL:', url);
      console.log('Using Token:', authToken ? 'Present' : 'Missing');

      const res = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Accept': 'application/json'
        }
      });
      
      console.log('Response status:', res.status);
      
      if (res.ok) {
        const data = await res.json();
        console.log('Fetched Data:', data);
        // Backend returns { status: true, data: [...] }
        const fetchedCars = data.data || data || [];
        setCars(Array.isArray(fetchedCars) ? fetchedCars : []);
      } else {
        const errorText = await res.text();
        console.error('Failed to fetch cars:', res.status, errorText);
        setCars([]);
      }
    } catch (error) {
      console.error('Error fetching cars:', error);
      setCars([]);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (authToken) {
        fetchCars(activeTab);
    }
     // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeTab, authToken]);

  useEffect(() => {
    setTitle('Auctions');
    
    // Set Tabs in the Header Search Content area
    setSearchContent(
      <div className="flex items-center bg-slate-100/80 p-1 rounded-xl border border-slate-200 shadow-inner">
        {AUCTION_STATUSES.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`px-4 py-1.5 rounded-lg text-[11px] font-bold transition-all duration-300 relative ${
              activeTab === tab.id
                ? 'bg-white text-blue-600 shadow-sm scale-100'
                : 'text-slate-500 hover:text-slate-700 hover:bg-white/40'
            }`}
          >
            {tab.label}
            {activeTab === tab.id && (
              <span className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-1 h-1 bg-blue-600 rounded-full" />
            )}
          </button>
        ))}
      </div>
    );

    setActionsContent(
      <div className="flex items-center gap-3">
        <div className="relative group">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 group-focus-within:text-blue-500 transition-colors" />
          <input
            type="text"
            placeholder="Search make, model, reg..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="h-9 pl-10 pr-4 text-xs border border-slate-200 bg-slate-50/50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-blue-500/5 focus:border-blue-500 rounded-xl w-64 transition-all"
          />
        </div>
        <button 
            className="flex items-center gap-2 px-3 h-9 text-xs font-bold text-slate-600 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-all shadow-sm active:scale-95"
            onClick={() => {/* Export logic */}}
        >
          <Download className="w-4 h-4" />
          Export
        </button>
      </div>
    );

    return () => {
      setSearchContent(null);
      setActionsContent(null);
    };
  }, [setTitle, setSearchContent, setActionsContent, activeTab, searchTerm]);

  const filteredCars = useMemo(() => {
    if (!searchTerm) return cars;
    const lowerSearch = searchTerm.toLowerCase();
    return cars.filter(car => 
      (car.make || '').toLowerCase().includes(lowerSearch) ||
      (car.model || '').toLowerCase().includes(lowerSearch) ||
      (car.carRegistrationNumber || '').toLowerCase().includes(lowerSearch) ||
      (car.variant || '').toLowerCase().includes(lowerSearch)
    );
  }, [cars, searchTerm]);

  const columns = [
    {
      header: 'Vehicle Description',
      render: (car: AuctionRecord) => (
        <div className="flex items-center gap-4 py-2">
          <div className="w-20 h-14 rounded-xl bg-slate-100 flex items-center justify-center overflow-hidden shrink-0 border border-slate-200 shadow-sm">
            {(car.imageUrl || car.carImages?.[0]) ? (
              <img 
                src={car.imageUrl || car.carImages?.[0]} 
                alt={car.model} 
                className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" 
              />
            ) : (
              <Car className="w-8 h-8 text-slate-300" />
            )}
          </div>
          <div className="flex flex-col gap-1">
            <div className="font-extrabold text-slate-900 text-[12px] flex items-center gap-2 leading-tight">
              {car.make} {car.model}
              <span className="text-[10px] font-bold text-blue-600 bg-blue-50 px-1.5 py-0.5 rounded uppercase tracking-wider">{car.variant}</span>
            </div>
            <div className="flex items-center gap-3">
              <span className="font-mono font-bold text-[11px] text-slate-500 bg-slate-100 px-1.5 py-0.5 rounded border border-slate-200">
                {car.carRegistrationNumber || 'N/A'}
              </span>
              <div className="flex items-center gap-1.5 text-[11px] text-slate-400 font-medium">
                <Calendar className="w-3.5 h-3.5" />
                {car.yearOfRegistration}
              </div>
              <div className="flex items-center gap-1.5 text-[11px] text-slate-400 font-medium">
                <MapPin className="w-3.5 h-3.5" />
                {car.location || 'Kolkata'}
              </div>
            </div>
          </div>
        </div>
      ),
      width: '450px'
    },
    {
      header: 'Mechanical Specs',
      render: (car: AuctionRecord) => (
        <div className="flex flex-col gap-1 py-2">
          <div className="flex items-center gap-2">
            <span className="font-bold text-slate-700 text-[12px]">{car.odometerReadingInKms?.toLocaleString() || '0'} km</span>
            <span className="text-[10px] font-bold text-slate-400">ODO</span>
          </div>
          <div className="flex items-center gap-2">
             <span className="px-2 py-0.5 bg-slate-100 text-slate-600 text-[10px] font-bold rounded-full border border-slate-200">
                {car.ownershipSerialNumber || '1st'} Owner
             </span>
          </div>
        </div>
      ),
      width: '180px'
    },
    {
      header: 'Status & Visibility',
      render: (car: AuctionRecord) => {
        const statusConfig = AUCTION_STATUSES.find(s => s.id === activeTab) || AUCTION_STATUSES[0];
        return (
          <div className="py-2">
            <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-tighter border-2 ${statusConfig.bg} ${statusConfig.color} ${statusConfig.borderColor} shadow-sm`}>
              <div className={`w-1.5 h-1.5 rounded-full mr-1.5 animate-pulse transition-colors ${statusConfig.id === 'live' ? 'bg-red-500' : 'bg-current'}`} />
              {statusConfig.label}
            </span>
          </div>
        );
      },
      width: '180px'
    },
    {
      header: 'Bidding Performance',
      render: (car: AuctionRecord) => (
        <div className="flex flex-col gap-1 py-2">
          <div className="flex items-center gap-1.5 text-blue-600 font-black text-[13px]">
            <TrendingUp className="w-4 h-4" />
            {(car.highestBid ?? 0).toLocaleString()}
          </div>
          <div className="flex items-center gap-2">
            <span className="text-[10px] font-bold text-slate-400 bg-slate-50 px-1.5 py-0.5 rounded border border-slate-100">
               {car.totalBids ?? 0} Bids
            </span>
            <span className="text-[10px] font-medium text-slate-300 tracking-wide">
               Base: {(car.basePrice ?? 0).toLocaleString()}
            </span>
          </div>
        </div>
      ),
      width: '220px'
    },
    {
      header: 'Auction Timeline',
      render: (car: AuctionRecord) => {
        const targetTime = activeTab === 'upcoming' 
          ? car.upcomingUntil 
          : (car.auctionEndTime || car.endTime);
          
        return (
          <div className="flex flex-col gap-1 py-1">
            <div className="flex items-center gap-2 px-2 py-1 bg-slate-50 rounded-lg border border-slate-100 group-hover:bg-white transition-colors">
              <Clock className={`w-4 h-4 ${activeTab === 'live' ? 'text-red-500 animate-pulse' : 'text-slate-400'}`} />
              <span className={`text-[11px] font-bold ${activeTab === 'live' ? 'text-red-600' : 'text-slate-600'}`}>
                  <CountdownTimer endTime={targetTime} />
              </span>
            </div>
            <div className="text-[9px] text-slate-400 font-bold uppercase tracking-widest pl-2">
               {activeTab === 'upcoming' ? 'Starts In' : 'Ends'}: {targetTime ? (
                 <>
                   {new Date(targetTime).toLocaleDateString([], { month: 'short', day: '2-digit' })} &middot; {new Date(targetTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false })}
                 </>
               ) : 'N/A'}
            </div>
          </div>
        );
      },
      width: '180px'
    },
    {
      header: '',
      render: (car: AuctionRecord) => (
        <button 
          onClick={() => {
            setSelectedCarId(car._id || car.id);
            setIsDetailsModalOpen(true);
          }}
          className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all active:scale-90 flex items-center gap-1 group/btn font-bold text-[10px]"
        >
           Manage
           <ChevronRight className="w-4 h-4 transition-transform group-hover/btn:translate-x-0.5" />
        </button>
      ),
      width: '100px',
      align: 'right' as const
    }
  ];

  return (
    <div className="h-full flex flex-col overflow-hidden bg-slate-50/30">
        <Table
          columns={columns.slice(0, -1)} // Remove the last column (Manage button)
          data={filteredCars}
          isLoading={isLoading}
          keyField="_id"
          onRowClick={(car) => {
            setSelectedCarId(car._id || car.id);
            setIsDetailsModalOpen(true);
          }}
          emptyMessage={`No vehicles found in ${activeTab || 'selected'} status.`}
        />

        <CarDetailsModal 
          carId={selectedCarId}
          isOpen={isDetailsModalOpen}
          onClose={() => setIsDetailsModalOpen(false)}
          authToken={authToken}
        />
    </div>
  );
}
