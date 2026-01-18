'use client';

import { useState, useEffect, useCallback, Suspense } from 'react';
import { Search, Plus, Download, Edit2, Trash2 } from 'lucide-react';
import { useHeader } from '@/context/HeaderContext';
import Table from '@/components/Table';
import SettingsSidebar from '@/components/SettingsSidebar';
import CarVarianceModal from '@/components/CarVarianceModal';
import GlobalImportModal from '@/components/GlobalImportModal';

interface CarVariance {
  _id: string;
  make: string;
  carModel: string;
  variant: string;
  price: number;
}

function CarVariancesPageContent() {
  const { setTitle, setSearchContent, setActionsContent } = useHeader();
  const [carVariances, setCarVariances] = useState<CarVariance[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [isCarVarianceModalOpen, setIsCarVarianceModalOpen] = useState(false);
  const [isImportModalOpen, setIsImportModalOpen] = useState(false);
  const [editingCarVariance, setEditingCarVariance] = useState<CarVariance | null>(null);

  // Pagination state
  const [currentPage, setCurrentPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const itemsPerPage = 50;

  const getBaseUrl = useCallback(() => process.env.NEXT_PUBLIC_BACKENDBASEURL || 'https://otobix-app-backend-development.onrender.com/api/', []);
  const AUTH_TOKEN = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MDBhYzc2NTA4OGQxYTA2ODc3MDU0NCIsInVzZXJOYW1lIjoiY3VzdG9tZXIiLCJ1c2VyVHlwZSI6IkN1c3RvbWVyIiwiaWF0IjoxNzY0MzMxNjMxLCJleHAiOjIwNzk2OTE2MzF9.oXw1J4ca1XoIAg-vCO2y0QqZIq0VWHdYBrl2y9iIv4Q';

  const fetchCarVariances = useCallback(async (page = 1) => {
    try {
      setLoading(true);
      const url = new URL(`${getBaseUrl()}${process.env.NEXT_PUBLIC_CAR_DROPDOWNS_LIST || 'admin/customers/car-dropdowns/get-list'}`);
      url.searchParams.append('page', page.toString());
      url.searchParams.append('limit', itemsPerPage.toString());
      if (searchTerm) url.searchParams.append('search', searchTerm);

      const res = await fetch(url.toString(), {
        headers: { 'Authorization': AUTH_TOKEN },
        cache: 'no-store'
      });
      if (res.ok) {
        const data = await res.json();
        const items = Array.isArray(data) ? data : (data.data || []);
        // Check multiple possible properties for total count and ensure it is a number
        const total = data.totalCount || data.count || data.total || (items.length === itemsPerPage ? items.length * 2 : items.length); 
        
        setCarVariances(items.map((c: any) => ({
          _id: c._id || c.id,
          make: c.make || '',
          carModel: c.model || c.carModel || '',
          variant: c.variant || '',
          price: c.price || 0
        })));
        setTotalCount(total);
      }
    } catch (err) {
      console.error('[Settings] Car variance fetch failed:', err);
    } finally {
      setLoading(false);
    }
  }, [getBaseUrl, AUTH_TOKEN, searchTerm]);

  useEffect(() => {
    fetchCarVariances(currentPage);
  }, [fetchCarVariances, currentPage]);

  useEffect(() => {
    setTitle('Car Variances');
    setSearchContent(
      <div className="relative group w-full max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search..."
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
          title="Import Car Variances"
        >
          <Download className="w-4 h-4" />
        </button>
        <button
          onClick={() => {
            setEditingCarVariance(null);
            setIsCarVarianceModalOpen(true);
          }}
          className="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white text-sm font-medium rounded-lg shadow-lg shadow-blue-500/20 hover:bg-blue-600 transition-colors"
        >
          <Plus className="w-4 h-4" /> Add Variance
        </button>
      </div>
    );
  }, [setTitle, setSearchContent, setActionsContent, searchTerm]);

  const handleUpdateCarVariance = async (data: Omit<CarVariance, '_id'>) => {
    try {
      if (editingCarVariance) {
        const url = `${getBaseUrl()}${process.env.NEXT_PUBLIC_EDIT_CAR_DROPDOWN || 'admin/customers/car-dropdowns/edit'}`;
        const res = await fetch(url, {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'Authorization': AUTH_TOKEN
          },
          body: JSON.stringify({ 
            carDropdownId: editingCarVariance._id,
            make: data.make,
            model: data.carModel,
            variant: data.variant,
            price: data.price
          }),
        });
        if (res.ok) fetchCarVariances();
      } else {
        const url = `${getBaseUrl()}${process.env.NEXT_PUBLIC_ADD_CAR_DROPDOWN || 'admin/customers/car-dropdowns/add'}`;
        const res = await fetch(url, {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'Authorization': AUTH_TOKEN
          },
          body: JSON.stringify({ 
            make: data.make,
            model: data.carModel,
            variant: data.variant,
            price: data.price
          }),
        });
        if (res.ok) fetchCarVariances();
      }
      setIsCarVarianceModalOpen(false);
      setEditingCarVariance(null);
    } catch (err) {
      console.error('[Settings] Car variance save failed:', err);
    }
  };

  const handleDeleteCarVariance = async (id: string) => {
    if (confirm('Are you sure you want to delete this car variance?')) {
      try {
        const url = `${getBaseUrl()}${process.env.NEXT_PUBLIC_DELETE_CAR_DROPDOWN || 'admin/customers/car-dropdowns/delete'}`;
        const res = await fetch(url, { 
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'Authorization': AUTH_TOKEN
          },
          body: JSON.stringify({ carDropdownId: id })
        });
        if (res.ok) fetchCarVariances();
      } catch (err) {
        console.error('[Settings] Car variance delete failed:', err);
      }
    }
  };

  const totalPages = Math.ceil(totalCount / itemsPerPage);
  // No client-side slicing needed as backend returns paginated data
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = Math.min(startIndex + itemsPerPage, totalCount);

  return (
    <div className="h-full flex bg-slate-50 overflow-hidden">
      <SettingsSidebar activeSection="car-variances" />
      
      <div className="flex-1 overflow-hidden flex flex-col p-4">
        <div className="bg-white border border-gray-100 rounded-xl shadow-sm overflow-hidden flex flex-col flex-1">
          <Table
            data={carVariances}
            isLoading={loading}
            columns={[
              {
                header: 'Make',
                accessor: 'make',
                className: 'font-medium text-slate-900',
              },
              {
                header: 'Model',
                accessor: 'carModel',
              },
              {
                header: 'Variant',
                accessor: 'variant',
              },
              {
                header: 'Price',
                render: (row: CarVariance) => (
                  <span className="font-mono text-slate-600">
                    {typeof row.price === 'number' ? row.price.toLocaleString() : '-'}
                  </span>
                ),
              },
              {
                header: '',
                accessor: '_id',
                className: 'w-10 text-right',
                render: (row: CarVariance) => (
                  <div className="flex justify-end gap-1">
                    <button
                      onClick={() => {
                        setEditingCarVariance(row);
                        setIsCarVarianceModalOpen(true);
                      }}
                      className="p-1.5 hover:bg-blue-50 text-blue-500 rounded-lg transition-colors"
                      title="Edit"
                    >
                      <Edit2 className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => handleDeleteCarVariance(row._id)}
                      className="p-1.5 hover:bg-red-50 text-red-500 rounded-lg transition-colors"
                      title="Delete"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                ),
              },
            ]}
            pagination={{
              currentPage,
              totalItems: totalCount,
              totalPages,
              startIndex,
              endIndex,
              canNext: currentPage < totalPages,
              canPrev: currentPage > 1,
              onNext: () => setCurrentPage((p) => Math.min(totalPages, p + 1)),
              onPrev: () => setCurrentPage((p) => Math.max(1, p - 1)),
              onSetPage: (p) => setCurrentPage(p),
            }}
          />
        </div>
      </div>

      <CarVarianceModal
        isOpen={isCarVarianceModalOpen}
        onClose={() => {
          setIsCarVarianceModalOpen(false);
          setEditingCarVariance(null);
        }}
        onSubmit={handleUpdateCarVariance}
        editItem={editingCarVariance}
      />

      <GlobalImportModal
        isOpen={isImportModalOpen}
        onClose={() => setIsImportModalOpen(false)}
        endpoint="/api/car-variances/import"
        onSuccess={() => {
          fetchCarVariances();
          setTimeout(() => setIsImportModalOpen(false), 1500);
        }}
        title="Import Car Variances"
      />
    </div>
  );
}

export default function CarVariancesPage() {
  return (
    <Suspense fallback={
       <div className="flex items-center justify-center min-h-screen">
          <div className="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin" />
       </div>
    }>
      <CarVariancesPageContent />
    </Suspense>
  );
}
