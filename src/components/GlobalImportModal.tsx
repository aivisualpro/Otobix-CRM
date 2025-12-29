'use client';

import { useState, DragEvent, ChangeEvent } from 'react';
import Papa from 'papaparse';
import { Upload, X, FileText, CheckCircle, Loader2 } from 'lucide-react';

interface GlobalImportModalProps {
  isOpen: boolean;
  onClose: () => void;
  endpoint: string;
  onSuccess?: () => void;
  title?: string;
}

interface ImportStats {
  total: number;
  processed: number;
  success: number;
  failed: number;
}

interface BatchResult {
  success: boolean;
  count: number;
  error?: string;
  inserted?: number;
  failed?: number;
  errors?: string[];
}

const GlobalImportModal = ({
  isOpen,
  onClose,
  endpoint,
  onSuccess,
  title = 'Import Data',
}: GlobalImportModalProps) => {
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [stats, setStats] = useState<ImportStats>({
    total: 0,
    processed: 0,
    success: 0,
    failed: 0,
  });
  const [logs, setLogs] = useState<string[]>([]);
  const [completed, setCompleted] = useState(false);

  const BATCH_SIZE = 2000;

  const resetState = () => {
    setFile(null);
    setUploading(false);
    setStats({ total: 0, processed: 0, success: 0, failed: 0 });
    setLogs([]);
    setCompleted(false);
  };

  const handleClose = () => {
    if (uploading) {
      if (window.confirm('Import is in progress. Are you sure you want to cancel?')) {
        resetState();
        onClose();
      }
    } else {
      resetState();
      onClose();
    }
  };

  const handleFileDrop = (e: DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    const droppedFile = e.dataTransfer.files[0];
    if (droppedFile && droppedFile.type === 'text/csv') {
      setFile(droppedFile);
    } else {
      alert('Please upload a CSV file.');
    }
  };

  const handleFileSelect = (e: ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0];
    if (selectedFile) setFile(selectedFile);
  };

  const processBatch = async (batch: Record<string, unknown>[]): Promise<BatchResult> => {
    try {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ records: batch }),
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Batch failed');
      return { success: true, count: batch.length, ...data };
    } catch (error) {
      console.error('Batch upload failed', error);
      return { success: false, count: batch.length, error: (error as Error).message };
    }
  };

  const handleImport = () => {
    if (!file) return;

    setUploading(true);
    setLogs((prev) => [...prev, `Starting import for ${file.name}...`]);

    let batch: Record<string, unknown>[] = [];
    let processedCount = 0;

    Papa.parse(file, {
      header: true,
      skipEmptyLines: true,
      step: async (results: Papa.ParseStepResult<Record<string, unknown>>, parser: Papa.Parser) => {
        parser.pause();

        batch.push(results.data);

        if (batch.length >= BATCH_SIZE) {
          const currentBatch = [...batch];
          batch = [];

          try {
            const result = await processBatch(currentBatch);
            processedCount += currentBatch.length;

            // Check if API returned detailed counts
            const inserted =
              typeof result.inserted === 'number'
                ? result.inserted
                : result.success
                  ? result.count
                  : 0;
            const failed =
              typeof result.failed === 'number'
                ? result.failed
                : !result.success
                  ? result.count
                  : 0;

            setStats((prev) => ({
              ...prev,
              processed: processedCount,
              success: prev.success + inserted,
              failed: prev.failed + failed,
            }));

            setLogs((prev) => [...prev, `Processed batch: ${inserted} added, ${failed} skipped`]);
            if (result.errors && Array.isArray(result.errors)) {
              result.errors.forEach((err: string) => setLogs((prev) => [...prev, `⚠ ${err}`]));
            }
          } catch (err) {
            setLogs((prev) => [...prev, `Batch failed: ${(err as Error).message}`]);
            setStats((prev) => ({
              ...prev,
              processed: processedCount,
              failed: prev.failed + currentBatch.length,
            }));
          }

          parser.resume();
        } else {
          parser.resume();
        }
      },
      complete: async () => {
        if (batch.length > 0) {
          const result = await processBatch(batch);
          processedCount += batch.length;

          const inserted =
            typeof result.inserted === 'number'
              ? result.inserted
              : result.success
                ? result.count
                : 0;
          const failed =
            typeof result.failed === 'number' ? result.failed : !result.success ? result.count : 0;

          setStats((prev) => ({
            ...prev,
            processed: processedCount,
            success: prev.success + inserted,
            failed: prev.failed + failed,
          }));

          setLogs((prev) => [...prev, `Processed batch: ${inserted} added, ${failed} skipped`]);
          if (result.errors && Array.isArray(result.errors)) {
            result.errors.forEach((err: string) => setLogs((prev) => [...prev, `⚠ ${err}`]));
          }
        }

        setUploading(false);
        setCompleted(true);
        setLogs((prev) => [...prev, 'Import completed successfully.']);
        if (onSuccess) onSuccess();
      },
      error: (err: Error) => {
        setUploading(false);
        setLogs((prev) => [...prev, `Error: ${err.message}`]);
      },
    });
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-lg overflow-hidden flex flex-col max-h-[90vh]">
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50">
          <h3 className="text-lg font-bold text-slate-800">{title}</h3>
          <button
            onClick={handleClose}
            className="p-1 hover:bg-gray-200 rounded-full transition-colors"
          >
            <X className="w-5 h-5 text-slate-500" />
          </button>
        </div>

        {/* Body */}
        <div className="p-6 flex-1 overflow-y-auto">
          {!uploading && !completed ? (
            <div
              className={`border-2 border-dashed rounded-xl p-8 flex flex-col items-center justify-center text-center transition-all
                ${file ? 'border-blue-500 bg-blue-50/50' : 'border-gray-300 hover:border-blue-500 hover:bg-gray-50'}`}
              onDragOver={(e) => e.preventDefault()}
              onDrop={handleFileDrop}
            >
              {file ? (
                <>
                  <FileText className="w-12 h-12 text-blue-500 mb-3" />
                  <p className="font-semibold text-slate-700">{file.name}</p>
                  <p className="text-sm text-slate-500 mt-1">
                    {(file.size / 1024 / 1024).toFixed(2)} MB
                  </p>
                  <button
                    onClick={() => setFile(null)}
                    className="mt-4 text-xs text-red-500 hover:text-red-700 font-medium underline"
                  >
                    Remove File
                  </button>
                </>
              ) : (
                <>
                  <Upload className="w-12 h-12 text-slate-400 mb-3" />
                  <p className="font-medium text-slate-600">Drag & Drop CSV file here</p>
                  <p className="text-sm text-slate-400 mt-1">or click to browse</p>
                  <input
                    type="file"
                    accept=".csv"
                    className="hidden"
                    id="file-upload"
                    onChange={handleFileSelect}
                  />
                  <label
                    htmlFor="file-upload"
                    className="mt-4 px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-slate-700 shadow-sm hover:bg-gray-50 cursor-pointer"
                  >
                    Browse Files
                  </label>
                </>
              )}
            </div>
          ) : (
            <div className="flex flex-col items-center justify-center py-4">
              {completed ? (
                <div className="text-center mb-6">
                  <div className="w-16 h-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto mb-3">
                    <CheckCircle className="w-8 h-8" />
                  </div>
                  <h4 className="text-xl font-bold text-slate-800">Import Complete</h4>
                  <p className="text-slate-500 mt-1">Processed all records successfully.</p>
                </div>
              ) : (
                <div className="text-center mb-6 w-full">
                  <div className="w-16 h-16 bg-blue-50 text-blue-500 rounded-full flex items-center justify-center mx-auto mb-3 animate-pulse">
                    <Loader2 className="w-8 h-8 animate-spin" />
                  </div>
                  <h4 className="text-lg font-bold text-slate-800">Importing Data...</h4>
                  <p className="text-slate-500 mt-1 text-sm">Please do not close this window.</p>
                </div>
              )}

              {/* Stats */}
              <div className="grid grid-cols-2 gap-4 w-full mb-6">
                <div className="bg-gray-50 p-3 rounded-lg text-center border border-gray-100">
                  <div className="text-2xl font-bold text-slate-800">
                    {stats.processed.toLocaleString()}
                  </div>
                  <div className="text-xs font-semibold text-slate-400 uppercase tracking-wider">
                    Processed
                  </div>
                </div>
                <div className="bg-gray-50 p-3 rounded-lg text-center border border-gray-100">
                  <div className="text-2xl font-bold text-green-600">
                    {stats.success.toLocaleString()}
                  </div>
                  <div className="text-xs font-semibold text-slate-400 uppercase tracking-wider">
                    Success
                  </div>
                </div>
              </div>

              {/* Logs */}
              <div className="w-full bg-slate-900 rounded-lg p-3 h-32 overflow-y-auto text-xs font-mono text-green-400">
                {logs.map((log, i) => (
                  <div key={i} className="mb-1">{`> ${log}`}</div>
                ))}
                {uploading && <div className="animate-pulse">_</div>}
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 bg-gray-50 border-t border-gray-100 flex justify-end gap-3 rounded-b-xl">
          <button
            onClick={handleClose}
            className="px-4 py-2 text-slate-600 font-medium hover:bg-gray-200 rounded-lg text-sm transition-colors"
            disabled={uploading}
          >
            {completed ? 'Close' : 'Cancel'}
          </button>
          {!uploading && !completed && (
            <button
              onClick={handleImport}
              disabled={!file}
              className={`px-6 py-2 rounded-lg font-medium text-sm shadow-lg shadow-blue-500/20 transition-all
                ${file ? 'bg-blue-500 text-white hover:bg-blue-600' : 'bg-gray-300 text-gray-500 cursor-not-allowed'}`}
            >
              Start Import
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default GlobalImportModal;
