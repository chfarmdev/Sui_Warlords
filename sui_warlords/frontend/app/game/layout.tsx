import GameHeader from "@/components/GameHeader"
import GameNavBar from "@/components/GameNavBar"

export default function GameLayout({
    children, // will be a page or nested layout
  }: {
    children: React.ReactNode
  }) {
    return (  
      <section>
          
        <div className="sticky z-50 w-full border-b border-solid pb-2">
          <GameHeader/>
        </div>
          
        <div className="flex h-[calc(100vh-84px)] space-x-2">
          <div className="w-1/7 rounded-xl border-4 border-black bg-gradient-to-b from-gray-600 to-gray-900 pr-2 pl-2 py-4">
            <GameNavBar/>
          </div>
            
          <div className="w-6/7 w-full rounded-xl border-4 border-black bg-gradient-to-b from-gray-600 to-gray-900 py-4">
            {children}
          </div>
        </div>
      </section>     
    )
  }

  