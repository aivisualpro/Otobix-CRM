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
  AlertCircle
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

  const backendBaseUrl = process.env.NEXT_PUBLIC_BACKENDBASEURL;
  const detailsPath = process.env.NEXT_PUBLIC_CAR_DETAILS;

  useEffect(() => {
    if (isOpen && carId && authToken) {
      fetchDetails();
    } else {
      setDetails(null);
      setActiveImage(0);
    }
  }, [isOpen, carId, authToken]);

  const fetchDetails = async () => {
    setIsLoading(true);
    try {
      const url = `${backendBaseUrl}${detailsPath}/${carId}`;
      const res = await fetch(url, {
        headers: { 'Authorization': `Bearer ${authToken}` }
      });
      if (res.ok) {
        const data = await res.json();
        setDetails(data.data || data);
      }
    } catch (error) {
      console.error('Fetch details error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm transition-all duration-300">
      <div className="bg-white w-full max-w-5xl h-[85vh] rounded-2xl shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in duration-300">
        {/* Modal Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-white sticky top-0 z-20">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-blue-50 rounded-lg">
              <Car className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <h3 className="text-lg font-black text-slate-800 leading-tight">
                {isLoading ? 'Loading vehicle...' : `${details?.make || ''} ${details?.model || ''}`}
              </h3>
              {!isLoading && (
                <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                  {details?.carRegistrationNumber} &bull; {details?.variant}
                </p>
              )}
            </div>
          </div>
          <button 
            onClick={onClose} 
            className="p-2 hover:bg-slate-100 rounded-full text-slate-400 hover:text-red-500 transition-all active:scale-90"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Content */}
        <div className="flex-1 overflow-auto custom-scrollbar p-6">
          {isLoading ? (
            <div className="h-full flex flex-col items-center justify-center gap-4 text-slate-400">
               <div className="w-12 h-12 border-4 border-blue-500/20 border-t-blue-500 rounded-full animate-spin" />
               <p className="font-bold text-sm tracking-widest uppercase">Fetching Records...</p>
            </div>
          ) : details ? (
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Left Column: Images & Key Info */}
              <div className="space-y-6">
                <div className="relative group">
                   <div className="aspect-[16/10] bg-slate-100 rounded-2xl overflow-hidden border border-slate-200">
                      <img 
                        src={details.carImages?.[activeImage] || details.imageUrl} 
                        alt="Car" 
                        className="w-full h-full object-cover"
                      />
                   </div>
                   {details.carImages?.length > 1 && (
                     <div className="mt-4 flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
                        {details.carImages.map((img: string, idx: number) => (
                           <button 
                             key={idx}
                             onClick={() => setActiveImage(idx)}
                             className={`w-20 h-14 rounded-lg overflow-hidden border-2 shrink-0 transition-all ${activeImage === idx ? 'border-blue-500 scale-105 shadow-md' : 'border-transparent opacity-60 hover:opacity-100'}`}
                           >
                             <img src={img} className="w-full h-full object-cover" />
                           </button>
                        ))}
                     </div>
                   )}
                </div>

                <div className="grid grid-cols-3 gap-4">
                   {[
                     { label: 'Highest Bid', value: `₹${(details.highestBid || 0).toLocaleString()}`, icon: TrendingUp, color: 'text-blue-600', bg: 'bg-blue-50' },
                     { label: 'Year', value: details.yearOfRegistration, icon: Calendar, color: 'text-amber-600', bg: 'bg-amber-50' },
                     { label: 'Fuel Type', value: details.fuelType || 'Diesel', icon: Fuel, color: 'text-emerald-600', bg: 'bg-emerald-50' }
                   ].map((item, idx) => (
                     <div key={idx} className={`${item.bg} p-4 rounded-xl border border-slate-100`}>
                        <item.icon className={`w-4 h-4 ${item.color} mb-2`} />
                        <div className="text-[10px] font-bold text-slate-500 uppercase tracking-tighter">{item.label}</div>
                        <div className={`text-sm font-black ${item.color}`}>{item.value}</div>
                     </div>
                   ))}
                </div>
              </div>

              {/* Right Column: Detailed Specs */}
              <div className="space-y-8">
                 <section>
                    <div className="flex items-center gap-2 mb-4">
                       <Info className="w-4 h-4 text-blue-500" />
                       <h4 className="text-xs font-black text-slate-800 uppercase tracking-widest">Configuration</h4>
                    </div>
                    <div className="grid grid-cols-2 gap-y-4 gap-x-8">
                       {[
                         { label: 'Transmission', value: details.transmission || 'Manual' },
                         { label: 'Kms Driven', value: `${(details.odometerReadingInKms || 0).toLocaleString()} KM` },
                         { label: 'Ownership', value: `${details.ownershipSerialNumber || 1}st Owner` },
                         { label: 'Body Type', value: details.bodyType || 'SUV' },
                         { label: 'Color', value: details.exteriorColor || 'White' },
                         { label: 'Engine Cap', value: details.engineCapacity || '2200 CC' }
                       ].map((spec, idx) => (
                         <div key={idx} className="flex flex-col">
                            <span className="text-[10px] font-bold text-slate-400 uppercase tracking-tighter">{spec.label}</span>
                            <span className="text-xs font-extrabold text-slate-700">{spec.value}</span>
                         </div>
                       ))}
                    </div>
                 </section>

                 <section className="bg-slate-50 p-6 rounded-2xl border border-slate-100">
                    <div className="flex items-center gap-2 mb-4">
                       <User className="w-4 h-4 text-blue-500" />
                       <h4 className="text-xs font-black text-slate-800 uppercase tracking-widest">Seller Context</h4>
                    </div>
                    <div className="flex items-center gap-4">
                       <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center border border-slate-200">
                          <User className="w-6 h-6 text-slate-400" />
                       </div>
                       <div>
                          <div className="text-sm font-black text-slate-800">{details.ownerName || 'Unknown Owner'}</div>
                          <div className="flex items-center gap-4 mt-1">
                             <div className="flex items-center gap-1 text-[11px] text-slate-500 font-bold">
                                <Phone className="w-3.5 h-3.5" />
                                {details.customerContactNumber || 'N/A'}
                             </div>
                             <div className="flex items-center gap-1 text-[11px] text-slate-500 font-bold">
                                <MapPin className="w-3.5 h-3.5" />
                                {details.location || 'Kolkata'}
                             </div>
                          </div>
                       </div>
                    </div>
                 </section>

                 <section>
                    <div className="flex items-center gap-2 mb-4">
                       <BadgeCheck className="w-4 h-4 text-emerald-500" />
                       <h4 className="text-xs font-black text-slate-800 uppercase tracking-widest">Valuation Summary</h4>
                    </div>
                    <div className="space-y-3">
                       <div className="flex items-center justify-between p-3 bg-blue-50 rounded-xl">
                          <span className="text-xs font-bold text-blue-700">Customer Expected Price</span>
                          <span className="text-sm font-black text-blue-800">₹{(details.customerExpectedPrice || 0).toLocaleString()}</span>
                       </div>
                       <div className="flex items-center justify-between p-3 bg-emerald-50 rounded-xl">
                          <span className="text-xs font-bold text-emerald-700">Highest Bidding Price</span>
                          <span className="text-sm font-black text-emerald-800">₹{(details.highestBid || 0).toLocaleString()}</span>
                       </div>
                    </div>
                 </section>
              </div>
            </div>
          ) : (
            <div className="h-full flex flex-col items-center justify-center text-slate-400">
               <AlertCircle className="w-12 h-12 mb-2" />
               <p>Unable to retrieve vehicle details.</p>
            </div>
          )}
        </div>

        {/* Modal Footer */}
        <div className="px-6 py-4 border-t border-slate-100 bg-slate-50/50 flex justify-end gap-3 z-20">
           <button 
             onClick={onClose}
             className="px-6 py-2 text-xs font-bold text-slate-500 hover:text-slate-800 transition-colors"
           >
             Close
           </button>
           <button className="px-6 py-2 bg-blue-600 text-white text-xs font-bold rounded-xl shadow-lg shadow-blue-500/20 hover:bg-blue-700 active:scale-95 transition-all">
             Print Inspection Report
           </button>
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
          columns={columns}
          data={filteredCars}
          isLoading={isLoading}
          keyField="_id"
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
