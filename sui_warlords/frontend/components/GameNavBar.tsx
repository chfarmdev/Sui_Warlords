import Link from 'next/link';
import Image from 'next/image';


export default function GameNavBar() {
    return (
    <>       
        <div className="w-full flex flex-col justify-between">
            <div className="grid gap-4 items-start justify-center">
                    
                <div className="relative group">
                    <Link href="/game/">
                        <div className="absolute -inset-1 bg-gradient-to-r from-pink-600 to-cyan-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/game.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Game
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Home
                            </span>
                        </button>
                    </Link>
                </div>

                <div className="relative group">
                    <Link href="/game/bazaar">
                        <div className="absolute -inset-1 bg-gradient-to-r from-cyan-600 to-pink-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/bazaar.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Bazaar
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Trade
                            </span>
                        </button>
                    </Link>
                </div>

                <div className="relative group">
                    <Link href="/game/hall">
                        <div className="absolute -inset-1 bg-gradient-to-r from-pink-600 to-cyan-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/hall.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Hall
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Mint
                            </span>
                        </button>
                    </Link>
                </div>
                
                <div className="relative group">
                    <Link href="/game/barracks">
                        <div className="absolute -inset-1 bg-gradient-to-r from-cyan-600 to-pink-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/barracks.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Barracks
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Level
                            </span>
                        </button>
                    </Link>
                </div>

                <div className="relative group">
                    <Link href="/game/temple">
                        <div className="absolute -inset-1 bg-gradient-to-r from-pink-600 to-cyan-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/temple.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Temple
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Class
                            </span>
                        </button>
                    </Link>
                </div>
                
                <div className="relative group">
                    <Link href="/game/camp">
                        <div className="absolute -inset-1 bg-gradient-to-r from-cyan-600 to-pink-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/camp.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Camp
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Loadouts
                            </span>
                        </button>
                    </Link>
                </div>

                <div className="relative group">
                    <Link href="/game/forge">
                        <div className="absolute -inset-1 bg-gradient-to-r from-pink-600 to-cyan-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/forge.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Forge
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Gear
                            </span>
                        </button>
                    </Link>
                </div>                

                <div className="relative group">
                    <Link href="/game/smithy">
                        <div className="absolute -inset-1 bg-gradient-to-r from-cyan-600 to-pink-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/smithy.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Smithy
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Enhance
                            </span>
                        </button>
                    </Link>
                </div>

                <div className="relative group">
                    <Link href="/game/artificer">
                        <div className="absolute -inset-1 bg-gradient-to-r from-pink-600 to-cyan-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/artificer.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Artificer
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Jewelry
                            </span>
                        </button>
                    </Link>
                </div>

                <div className="relative group">
                    <Link href="/game/dungeons">
                        <div className="absolute -inset-1 bg-gradient-to-r from-cyan-600 to-pink-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/dungeons.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Dungeons
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Quest
                            </span>
                        </button>
                    </Link>
                </div>

                <div className="relative group">
                    <Link href="/game/colliseum">
                        <div className="absolute -inset-1 bg-gradient-to-r from-pink-600 to-cyan-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/colliseum.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Colliseum
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">PvP
                            </span>
                        </button>
                    </Link>
                </div>

                <div className="relative group">
                    <Link href="/game/prospector">
                        <div className="absolute -inset-1 bg-gradient-to-r from-cyan-600 to-pink-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/prospector.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Prospector
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Land
                            </span>
                        </button>
                    </Link>
                </div>

                <div className="relative group">
                    <Link href="/game/guildhall">
                        <div className="absolute -inset-1 bg-gradient-to-r from-pink-600 to-cyan-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/guildhall.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Guild Hall
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Guilds
                            </span>
                        </button>
                    </Link>
                </div>

                <div className="relative group">
                    <Link href="/game/blackmarket">
                        <div className="absolute -inset-1 bg-gradient-to-r from-cyan-600 to-pink-600 rounded-lg blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt">
                        </div>
                        <button className="relative w-full p-2 bg-black rounded-lg leading-none flex items-center divide-x divide-gray-600">
                            <span className="flex items-center space-x-2">
                                <Image className="h-6 w-6" src="/blackmarket.svg" width={15} height={15} alt="SW"/>
                                <span className="pr-2 text-gray-100 font-bold">Black Market
                                </span>
                            </span>
                            <span className="pl-2 text-cyan-600 group-hover:text-gray-100 transition duration-200">Shop
                            </span>
                        </button>
                    </Link>
                </div>
                
            </div>           
        </div>               
    </>
    );
}