'use client';

import Image from 'next/image';
import { useState } from 'react';
import { ConnectModal, useCurrentAccount } from '@mysten/dapp-kit';


export default function GameHeader() {
  const currentAccount = useCurrentAccount();
	const [open, setOpen] = useState(false);
  
  return (
    <>
      <header className="flex flex-row bg-gradient-to-b from-neutral-700 to-neutral-400 h-75">
        <div className="flex basis-1/3">
          <Image src="/sw.jpg" width={75} height={75} alt="SW"/>
        </div>

        <div className="flex basis-1/3">
          <ul className="flex basis-full flex-row justify-evenly self-center">
            <li><a>Game Nav 1</a></li>
            <li><a>Game Nav 2</a></li>                   
            <li><a>Game Nav 3</a></li>
          </ul>
        </div>
        
        <div className="flex justify-end pr-5 basis-1/3">
          <div className="bg-cyan-400 hover:bg-cyan-700 text-white self-center font-bold py-3 px-5 rounded-full">          
            <ConnectModal
              trigger={
              <button disabled={!!currentAccount}> {currentAccount ? 'Connected' : 'Connect Wallet'}</button>
              }
              open={open}
              onOpenChange={(isOpen) => setOpen(isOpen)}
              />
          </div>
        </div>
      </header>      
    </>
  );
}

