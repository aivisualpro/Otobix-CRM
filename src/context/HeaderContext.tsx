'use client';

import { createContext, useContext, useState, ReactNode, Dispatch, SetStateAction } from 'react';

interface HeaderContextType {
  title: string;
  setTitle: Dispatch<SetStateAction<string>>;
  searchContent: ReactNode | null;
  setSearchContent: Dispatch<SetStateAction<ReactNode | null>>;
  actionsContent: ReactNode | null;
  setActionsContent: Dispatch<SetStateAction<ReactNode | null>>;
}

const HeaderContext = createContext<HeaderContextType | undefined>(undefined);

interface HeaderProviderProps {
  children: ReactNode;
}

export function HeaderProvider({ children }: HeaderProviderProps) {
  const [title, setTitle] = useState<string>('');
  const [searchContent, setSearchContent] = useState<ReactNode | null>(null);
  const [actionsContent, setActionsContent] = useState<ReactNode | null>(null);

  return (
    <HeaderContext.Provider
      value={{
        title,
        setTitle,
        searchContent,
        setSearchContent,
        actionsContent,
        setActionsContent,
      }}
    >
      {children}
    </HeaderContext.Provider>
  );
}

export function useHeader(): HeaderContextType {
  const context = useContext(HeaderContext);
  if (!context) {
    throw new Error('useHeader must be used within a HeaderProvider');
  }
  return context;
}
