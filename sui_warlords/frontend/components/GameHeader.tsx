'use client';

import Image from 'next/image';
import { useState } from 'react';
import { ConnectModal, useCurrentAccount } from '@mysten/dapp-kit';
import { useQuery } from '@tanstack/react-query';

import { request } from 'graphql-request';
import { allBalances, BalanceType } from '@/graphql/queries';


export function SuiBalance() {
  const account = useCurrentAccount();
  const address = account ? account.address : null;
  const sui = "0x0000000000000000000000000000000000000000000000000000000000000002::sui::SUI"
  
  const { data, error, isLoading, isSuccess } = useQuery({
    queryKey: ['suibalance', address, sui],
    queryFn: async () =>
      request<BalanceType>(
        'https://sui-testnet.mystenlabs.com/graphql',
        allBalances,        
        {address: address, type: sui},       
      ),      
  })

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error...</div>;
  }

  if (isSuccess) {
    console.log (data);
    console.log (data.address.balance.totalBalance);
    const suibalance = (Math.round(data.address.balance.totalBalance) / 1000000000).toFixed(2);
  return (
    <h1>SUI: {suibalance}</h1>
  )}
};

export function TimeBalance() {
  const account = useCurrentAccount();
  const address = account ? account.address : null;  
  const time = "0xaccb4a10ab5b5761393fcb9901d21eb1e4978864f7a53526600ff1f39faee5ea::time::TIME"

  const { data, error, isLoading, isSuccess } = useQuery({
    queryKey: ['timebalance', address, time],
    queryFn: async () =>
      request<BalanceType>(
        'https://sui-testnet.mystenlabs.com/graphql',
        allBalances,
        {address: address, type: time},
      ),
  })

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error...</div>;
  }

  if (isSuccess) {
    console.log (data);
    console.log (data.address.balance.totalBalance);
    const timebalance = (data.address.balance.totalBalance);
  return (
    <h1>TIME: {timebalance}</h1>
  )}
};

export function BloodBalance() {
  const account = useCurrentAccount();
  const address = account ? account.address : null;  
  const blood = "0xaccb4a10ab5b5761393fcb9901d21eb1e4978864f7a53526600ff1f39faee5ea::blood::BLOOD"

  const { data, error, isLoading, isSuccess } = useQuery({
    queryKey: ['bloodbalance', address, blood],
    queryFn: async () =>
      request<BalanceType>(
        'https://sui-testnet.mystenlabs.com/graphql',
        allBalances,
        {address: address, type: blood},
      ),
  })

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error...</div>;
  }

  if (isSuccess) {
    console.log (data);
    console.log (data.address.balance.totalBalance);
    const bloodbalance = (data.address.balance.totalBalance);
  return (
    <h1>BLOOD: {bloodbalance}</h1>
  )}
};


export default function GameHeader() {
  const currentAccount = useCurrentAccount();
	const [open, setOpen] = useState(false);
   
  return (
    <>
      <header className="flex flex-row bg-gradient-to-b from-neutral-700 to-neutral-400 h-75">
        
        <div className="flex basis-1/5">
          <Image src="/sw.jpg" width={75} height={75} alt="Sui Warlords" priority/>
        </div>

        <div className="flex basis-3/5">
          <ul className="flex basis-full flex-row justify-evenly self-center">
            <li> <SuiBalance /> </li>            
            <li> <TimeBalance/> </li>                   
            <li> <BloodBalance /> </li>
            <li></li>
            <li></li> 
            <li></li> 
            <li></li> 
            <li></li>            
          </ul>          
        </div>
        
        <div className="flex justify-end pr-5 basis-1/5">
          <div className="bg-cyan-400 hover:bg-cyan-700 text-white self-center font-bold py-3 px-5 rounded-full">          
            <ConnectModal
              trigger={
              <button disabled={!!currentAccount}> {currentAccount ? 'Connected' : 'Connect Wallet'} </button>
              }
              open={open}
              onOpenChange={(isOpen) => setOpen(isOpen)                            
              }              
              />
          </div>
        </div>

      </header>      
    </>
  );
}

