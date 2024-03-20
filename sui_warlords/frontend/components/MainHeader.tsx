import Image from 'next/image';
import Link from 'next/link';


export default function MainHeader() {  
  return (
    <>
        <header className="flex flex-row bg-gradient-to-b from-neutral-700 to-neutral-400 h-75"> {/* 75 Pixels */}
            <div className="flex basis-1/3">
            <Image src="/sw.jpg" width={75} height={75} alt="SW"/>
            </div>

            <div className="flex basis-1/3">
            <ul className="flex basis-full flex-row justify-evenly self-center">
                <li><a>Item 1</a></li>
                <li><a>Item 2</a></li>                   
                <li><a>Item 3</a></li>
            </ul>
            </div>
        
            <div className="flex justify-end pr-5 basis-1/3">
            <Link className="bg-cyan-400 hover:bg-cyan-700 text-white self-center font-bold py-3 px-5 rounded-full" href="/game">Play SUI Warlords</Link>
            </div>
        </header>
    </>    
  );
}

