'use client';

import { 
  ChevronLeft, 
  ChevronRight, 
  Loader2, 
  LayoutGrid, 
  ArrowUp, 
  ArrowDown, 
  Filter, 
  Calendar as CalendarIcon,
  Search,
  Check,
  ChevronsUpDown,
  X
} from 'lucide-react';
import { ReactNode, useState, useMemo } from 'react';
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Checkbox } from "@/components/ui/checkbox";
import { Calendar } from "@/components/ui/calendar";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

export interface Column<T> {
  id?: string;
  header: string;
  accessor?: keyof T;
  render?: (row: T) => ReactNode;
  className?: string;
  align?: 'left' | 'right';
  width?: string;
  sortable?: boolean;
  filterable?: boolean;
  type?: 'text' | 'number' | 'date' | 'boolean' | 'enum';
  options?: { label: string; value: any }[];
}

interface PaginationProps {
  currentPage: number;
  totalItems: number;
  totalPages: number;
  startIndex: number;
  endIndex: number;
  onNext: () => void;
  onPrev: () => void;
  onSetPage: (page: number) => void;
  canNext: boolean;
  canPrev: boolean;
}

interface TableProps<T> {
  columns: Column<T>[];
  data: T[];
  keyField?: keyof T;
  isLoading?: boolean;
  pagination?: PaginationProps;
  onRowClick?: (row: T) => void;
  emptyMessage?: string;
  toolbar?: ReactNode;
  onSort?: (columnId: string, direction: 'asc' | 'desc' | null) => void;
  onFilter?: (columnId: string, value: any) => void;
  activeFilters?: Record<string, any>;
  activeSort?: { columnId: string; direction: 'asc' | 'desc' } | null;
}

function Table<T extends object>({
  columns,
  data,
  keyField = 'id' as keyof T,
  isLoading = false,
  pagination,
  onRowClick,
  emptyMessage = 'No records found',
  toolbar,
  onSort,
  onFilter,
  activeFilters = {},
  activeSort = null,
}: TableProps<T>) {
  return (
    <div className="flex flex-col h-full bg-white overflow-hidden">
      {/* Toolbar - Pinned at top */}
      {toolbar && <div className="flex-none border-b border-gray-200 bg-white z-20">{toolbar}</div>}

      {/* Scrollable Table Area */}
      <div className="flex-1 overflow-auto bg-white custom-scrollbar">
        <table className="w-full text-left border-collapse">
          <thead className="sticky top-0 z-10 bg-slate-50 border-b border-gray-200">
            <tr>
              {columns.map((col, index) => {
                const columnId = col.id || String(col.accessor || index);
                const isSorted = activeSort?.columnId === columnId;
                const filterActive = !!activeFilters[columnId];

                return (
                  <th
                    key={index}
                    className={`py-2 text-[10px] font-bold uppercase tracking-wider text-slate-800 whitespace-nowrap group 
                      ${index === 0 ? 'pl-2 pr-2' : 'px-2'} 
                      ${col.className || ''} 
                      ${col.align === 'right' ? 'text-right' : 'text-left'}`}
                    style={{ width: col.width }}
                  >
                    <div className={cn("flex items-center gap-1.5", col.align === 'right' && "justify-end")}>
                      <span>{col.header}</span>
                      
                      {(col.sortable !== false || col.filterable !== false) && (
                        <Popover>
                          <PopoverTrigger asChild>
                            <button className={cn(
                              "p-1 hover:bg-slate-200 rounded transition-all opacity-0 group-hover:opacity-100",
                              (isSorted || filterActive) && "opacity-100 text-blue-600"
                            )}>
                              <LayoutGrid className="w-3 h-3" />
                            </button>
                          </PopoverTrigger>
                          <PopoverContent className="w-64 p-3 shadow-xl border-slate-200" align={col.align === 'right' ? 'end' : 'start'}>
                            <div className="space-y-3">
                              {/* Sort Options */}
                              {col.sortable !== false && (
                                <div className="space-y-1">
                                  <p className="text-[10px] uppercase font-bold text-slate-400 mb-2">Sorting</p>
                                  <div className="flex flex-col gap-1">
                                    <Button
                                      variant="ghost" 
                                      size="sm" 
                                      className={cn("justify-start h-8 text-xs", activeSort?.columnId === columnId && activeSort.direction === 'asc' && "bg-blue-50 text-blue-600")}
                                      onClick={() => onSort?.(columnId, 'asc')}
                                    >
                                      <ArrowUp className="w-3.5 h-3.5 mr-2" /> Sort Ascending
                                    </Button>
                                    <Button 
                                      variant="ghost" 
                                      size="sm" 
                                      className={cn("justify-start h-8 text-xs", activeSort?.columnId === columnId && activeSort.direction === 'desc' && "bg-blue-50 text-blue-600")}
                                      onClick={() => onSort?.(columnId, 'desc')}
                                    >
                                      <ArrowDown className="w-3.5 h-3.5 mr-2" /> Sort Descending
                                    </Button>
                                    {(isSorted) && (
                                      <Button variant="ghost" size="sm" className="justify-start h-8 text-xs text-red-500 hover:text-red-600" onClick={() => onSort?.(columnId, null)}>
                                        <X className="w-3.5 h-3.5 mr-2" /> Clear Sort
                                      </Button>
                                    )}
                                  </div>
                                </div>
                              )}

                              {/* Filter Options */}
                              {col.filterable !== false && (
                                <div className="space-y-2 pt-2 border-t border-slate-100">
                                  <div className="flex items-center justify-between mb-2">
                                    <p className="text-[10px] uppercase font-bold text-slate-400">Filter</p>
                                    {filterActive && (
                                      <button 
                                        onClick={() => onFilter?.(columnId, null)}
                                        className="text-[10px] text-blue-600 hover:underline font-medium"
                                      >
                                        Clear
                                      </button>
                                    )}
                                  </div>
                                  
                                  <FilterUI 
                                    column={col} 
                                    value={activeFilters[columnId]} 
                                    onChange={(val) => onFilter?.(columnId, val)} 
                                  />
                                </div>
                              )}
                            </div>
                          </PopoverContent>
                        </Popover>
                      )}
                    </div>
                  </th>
                );
              })}
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {isLoading ? (
              <tr>
                <td
                  colSpan={columns.length}
                  className="px-4 py-20 h-[calc(100vh-400px)] text-center text-slate-400"
                >
                  <div className="flex flex-col items-center justify-center gap-2">
                    <Loader2 className="w-6 h-6 animate-spin text-blue-500" />
                    <span className="text-xs">Loading data...</span>
                  </div>
                </td>
              </tr>
            ) : data.length > 0 ? (
              data.map((row, rowIndex) => (
                <tr
                  key={((row as any)[keyField] ?? rowIndex).toString()}
                  onClick={() => onRowClick && onRowClick(row)}
                  className={`
                    group transition-colors 
                    ${onRowClick ? 'cursor-pointer hover:bg-blue-50/50' : 'hover:bg-gray-50/80'}
                    ${rowIndex % 2 === 0 ? 'bg-white' : 'bg-slate-50/30'} 
                  `}
                >
                  {columns.map((col, colIndex) => (
                    <td
                      key={`${rowIndex}-${colIndex}`}
                      className={`py-1 text-[10px] text-slate-800 border-r border-transparent last:border-r-0 
                        ${colIndex === 0 ? 'pl-2 pr-2' : 'px-2'} 
                        ${col.className || ''} 
                        ${col.align === 'right' ? 'text-right' : 'text-left'}`}
                    >
                      {col.render
                        ? col.render(row)
                        : col.accessor
                          ? String((row as Record<string, unknown>)[col.accessor as string] ?? '')
                          : ''}
                    </td>
                  ))}
                </tr>
              ))
            ) : (
              <tr>
                <td
                  colSpan={columns.length}
                  className="px-4 py-12 text-center text-slate-400 text-sm"
                >
                  {emptyMessage}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {pagination && (
        <div className="flex-none flex flex-wrap items-center justify-between gap-4 py-1.5 px-2 border-t border-gray-200 text-[11px] text-slate-500 bg-slate-50">
          <div>
            Showing <span className="font-medium text-slate-900">{pagination.startIndex + 1}</span>{' '}
            to{' '}
            <span className="font-medium text-slate-900">
              {Math.min(pagination.endIndex, pagination.totalItems)}
            </span>{' '}
            of <span className="font-medium text-slate-900">{pagination.totalItems}</span>
          </div>

          <div className="flex items-center gap-4">
            <div className="flex items-center gap-1">
              <button
                onClick={pagination.onPrev}
                disabled={!pagination.canPrev}
                className="p-1 border border-gray-200 bg-white hover:bg-gray-50 text-slate-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors rounded"
              >
                <ChevronLeft className="w-3 h-3" />
              </button>

              <div className="flex items-center gap-1">
                {(() => {
                  const pages: ReactNode[] = [];
                  const { currentPage, totalPages, onSetPage } = pagination;

                  let startPage = Math.max(1, currentPage - 2);
                  let endPage = Math.min(totalPages, startPage + 4);

                  if (endPage - startPage < 4) {
                    startPage = Math.max(1, endPage - 4);
                  }

                  for (let i = startPage; i <= endPage; i++) {
                    pages.push(
                      <button
                        key={i}
                        onClick={() => onSetPage(i)}
                        className={`w-7 h-7 flex items-center justify-center border transition-colors rounded ${
                          currentPage === i
                            ? 'bg-blue-500 text-white border-blue-500 font-bold'
                            : 'bg-white text-slate-600 border-gray-200 hover:bg-gray-50'
                        }`}
                      >
                        {i}
                      </button>
                    );
                  }
                  return pages;
                })()}
              </div>

              <button
                onClick={pagination.onNext}
                disabled={!pagination.canNext}
                className="p-1 border border-gray-200 bg-white hover:bg-gray-50 text-slate-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors rounded"
              >
                <ChevronRight className="w-3 h-3" />
              </button>
            </div>

            <div className="flex items-center gap-2">
              <span className="text-slate-400">Go to</span>
              <div className="relative">
                <input
                  type="text"
                  className="w-10 h-7 px-1 text-center border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 rounded"
                  placeholder={String(pagination.currentPage)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      const target = e.target as HTMLInputElement;
                      const page = parseInt(target.value);
                      if (page >= 1 && page <= pagination.totalPages) {
                        pagination.onSetPage(page);
                        target.value = '';
                        target.blur();
                      }
                    }
                  }}
                />
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function FilterUI<T>({ column, value, onChange }: { column: Column<T>, value: any, onChange: (val: any) => void }) {
  const type = column.type || 'text';

  switch (type) {
    case 'boolean':
      return (
        <div className="flex p-1 bg-slate-100 rounded-md">
          <button 
            onClick={() => onChange(value === true ? null : true)}
            className={cn(
              "flex-1 py-1.5 text-[10px] font-bold rounded transition-all",
              value === true ? "bg-white text-blue-600 shadow-sm" : "text-slate-500 hover:text-slate-700 hover:bg-slate-200/50"
            )}
          >
            Yes
          </button>
          <button 
            onClick={() => onChange(value === false ? null : false)}
            className={cn(
              "flex-1 py-1.5 text-[10px] font-bold rounded transition-all",
              value === false ? "bg-white text-blue-600 shadow-sm" : "text-slate-500 hover:text-slate-700 hover:bg-slate-200/50"
            )}
          >
            No
          </button>
        </div>
      );

    case 'date':
      return (
        <div className="space-y-2">
          <Popover>
            <PopoverTrigger asChild>
              <Button
                variant={"outline"}
                size="sm"
                className={cn(
                  "w-full justify-start text-left font-normal h-8 text-xs",
                  !value && "text-muted-foreground"
                )}
              >
                <CalendarIcon className="mr-2 h-3.5 w-3.5" />
                {value?.from ? (
                  value.to ? (
                    <>
                      {new Date(value.from).toLocaleDateString()} - {new Date(value.to).toLocaleDateString()}
                    </>
                  ) : (
                    new Date(value.from).toLocaleDateString()
                  )
                ) : (
                  <span>Pick a date range</span>
                )}
              </Button>
            </PopoverTrigger>
            <PopoverContent className="w-auto p-0" align="start">
              <Calendar
                initialFocus
                mode="range"
                defaultMonth={value?.from}
                selected={value}
                onSelect={onChange}
                numberOfMonths={1}
              />
            </PopoverContent>
          </Popover>
        </div>
      );

    case 'number':
      return (
        <div className="grid grid-cols-2 gap-2">
          <div className="space-y-1">
            <label className="text-[10px] text-slate-400 font-bold uppercase tracking-tight">Min</label>
            <Input 
              type="number" 
              className="h-7 text-xs px-2 focus-visible:ring-blue-500/20" 
              placeholder="0"
              value={value?.min ?? ''} 
              onChange={(e) => onChange({ ...value, min: e.target.value })}
            />
          </div>
          <div className="space-y-1">
            <label className="text-[10px] text-slate-400 font-bold uppercase tracking-tight">Max</label>
            <Input 
              type="number" 
              className="h-7 text-xs px-2 focus-visible:ring-blue-500/20" 
              placeholder="Max"
              value={value?.max ?? ''} 
              onChange={(e) => onChange({ ...value, max: e.target.value })}
            />
          </div>
        </div>
      );

    case 'enum':
      // If exactly 2 options, show as a segmented toggle
      if (column.options?.length === 2) {
        return (
          <div className="flex p-1 bg-slate-100 rounded-md">
            {column.options.map((opt) => (
              <button
                key={opt.value}
                onClick={() => {
                  const current = Array.isArray(value) ? value : [];
                  if (current.includes(opt.value)) {
                    onChange(current.filter(v => v !== opt.value));
                  } else {
                    onChange([...current, opt.value]);
                  }
                }}
                className={cn(
                  "flex-1 py-1.5 text-[10px] font-bold rounded transition-all",
                  (Array.isArray(value) && value.includes(opt.value)) 
                    ? "bg-white text-blue-600 shadow-sm" 
                    : "text-slate-500 hover:text-slate-700 hover:bg-slate-200/50"
                )}
              >
                {opt.label}
              </button>
            ))}
          </div>
        );
      }
      return (
        <div className="space-y-2 max-h-48 overflow-y-auto pr-1 custom-scrollbar">
          {column.options?.map((opt) => (
            <div key={opt.value} className="flex items-center space-x-2">
              <Checkbox 
                id={`enum-${opt.value}`} 
                checked={(value || []).includes(opt.value)}
                onCheckedChange={(checked) => {
                  const current = value || [];
                  if (checked) {
                    onChange([...current, opt.value]);
                  } else {
                    onChange(current.filter((v: any) => v !== opt.value));
                  }
                }}
              />
              <label htmlFor={`enum-${opt.value}`} className="text-xs font-medium cursor-pointer">{opt.label}</label>
            </div>
          ))}
        </div>
      );

    default:
      return (
        <div className="relative">
          <Search className="absolute left-2 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400" />
          <Input 
            className="h-8 pl-8 text-xs" 
            placeholder="Filter..." 
            value={value || ''}
            onChange={(e) => onChange(e.target.value)}
          />
        </div>
      );
  }
}

export default Table;
