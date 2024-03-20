import Image from 'next/image';
import MainHeader from '@/components/MainHeader';


export default function Home() {
  return (
    <>
   
      <MainHeader/>     

      <main className="w-full h-[calc(100vh-147px)] rounded-xl border-4 border-black bg-gradient-to-b from-gray-600 to-gray-900 py-4">
        <h1>HomePage, app.page.tsx!</h1>        
        <p>Game info, strategy RPG, built on sui/etc</p>        
      </main>      
      
      <div className="flex flex-row bg-gradient-to-b from-neutral-700 to-neutral-400 h-85"> {/* 85 Pixels */}
        <div className="flex h-full w-1/2 font-semibold">
          <p>SUI Warlords<br/>Lost in the Woods<br/>Copyright © 2024 - All right reserved</p>
        </div>

        <div className="flex flex-col justify-center h-full w-1/2">
          <h1 className="flex justify-center font-semibold pt-2">Social</h1> 
          <div className="grid grid-flow-col justify-center gap-4">
            <a className="hover: "href="https://discord.com"><Image src="/discord.svg" width={25} height={25} alt="Discord"/></a>
            <a href="https://docs.suiwarlords.com"><Image src="/docs.svg" width={25} height={25} alt="Docs"/></a>
            <a href="https://github.com/chfarmdev/Sui_Warlords/tree/main/sui_warlords"><Image src="/github.svg" width={25} height={25} alt="Github"/></a>           
            <a href="https://twitter.com"><Image src="/x.svg" width={25} height={25} alt="X" /></a>            
          </div>
        </div>        
      </div>      
    </>
  );
}
