import { useState, useEffect, FormEvent } from 'react';
import { X } from 'lucide-react';

interface CarVariance {
  _id: string;
  make: string;
  carModel: string;
  variant: string;
  price: number;
}

interface CarVarianceModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: Omit<CarVariance, '_id'>) => void;
  editItem?: CarVariance | null;
}

const CarVarianceModal = ({ isOpen, onClose, onSubmit, editItem }: CarVarianceModalProps) => {
  const [make, setMake] = useState(editItem?.make || '');
  const [carModel, setCarModel] = useState(editItem?.carModel || '');
  const [variant, setVariant] = useState(editItem?.variant || '');
  const [price, setPrice] = useState(editItem?.price || 0);

  useEffect(() => {
    if (editItem) {
      setMake(editItem.make);
      setCarModel(editItem.carModel);
      setVariant(editItem.variant);
      setPrice(editItem.price);
    } else {
      setMake('');
      setCarModel('');
      setVariant('');
      setPrice(0);
    }
  }, [editItem, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    onSubmit({ make, carModel, variant, price: Number(price) });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
      <div className="bg-white shadow-2xl w-full max-w-lg border border-gray-100 rounded-xl">
        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center">
          <h2 className="text-lg font-bold text-slate-900">
            {editItem ? 'Edit Car Variance' : 'Add Car Variance'}
          </h2>
          <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-lg">
            <X className="w-5 h-5 text-slate-500" />
          </button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1">Make *</label>
              <input
                type="text"
                required
                className="form-input"
                placeholder="Toyota"
                value={make}
                onChange={(e) => setMake(e.target.value)}
              />
            </div>
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1">Model *</label>
              <input
                type="text"
                required
                className="form-input"
                placeholder="Corolla"
                value={carModel}
                onChange={(e) => setCarModel(e.target.value)}
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1">Variant *</label>
              <input
                type="text"
                required
                className="form-input"
                placeholder="GLi"
                value={variant}
                onChange={(e) => setVariant(e.target.value)}
              />
            </div>
            <div>
              <label className="block text-xs font-semibold text-slate-500 mb-1">Price *</label>
              <input
                type="number"
                required
                className="form-input"
                placeholder="0"
                value={price}
                onChange={(e) => setPrice(Number(e.target.value))}
              />
            </div>
          </div>
          <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
            <button type="button" onClick={onClose} className="btn-secondary">
              Cancel
            </button>
            <button type="submit" className="btn-primary">
              {editItem ? 'Update' : 'Create'} Variance
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default CarVarianceModal;
