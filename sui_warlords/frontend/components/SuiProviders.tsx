'use client';

import { createNetworkConfig, SuiClientProvider, WalletProvider } from '@mysten/dapp-kit';
import { getFullnodeUrl } from '@mysten/sui.js/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import '@mysten/dapp-kit/dist/index.css';

import { ReactQueryDevtools } from '@tanstack/react-query-devtools'


// Config options for the networks you want to connect to
const { networkConfig, useNetworkVariable } = createNetworkConfig({
	testnet: {
		url: getFullnodeUrl('testnet'),
		variables: {
			myMovePackageId: '0x1c28f08ae2755860f85d287d178f41b90109e7e24dbbc50b7142ad7a5d318c12',
		}
	},
	mainnet: {
		url: getFullnodeUrl('mainnet'),
		variables: {
			myMovePackageId: '0x456',
		}
	},
});

function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        // With SSR, we usually want to set some default staleTime
        // above 0 to avoid refetching immediately on the client
        staleTime: 60 * 1000,
      },
    },
  })
}

let browserQueryClient: QueryClient | undefined = undefined

function getQueryClient() {
  if (typeof window === 'undefined') {
    // Server: always make a new query client
    return makeQueryClient()
  } else {
    // Browser: make a new query client if we don't already have one
    // This is very important so we don't re-make a new client if React
    // suspends during the initial render. This may not be needed if we
    // have a suspense boundary BELOW the creation of the query client
    if (!browserQueryClient) browserQueryClient = makeQueryClient()
    return browserQueryClient
  }
}
 
export function SuiProviders({ children }: any) {
	
	const queryClient = getQueryClient();
	
	return (
    <QueryClientProvider client={queryClient}>     
      <SuiClientProvider networks={networkConfig} defaultNetwork="testnet">
        <WalletProvider autoConnect={true}>
            {children}
          </WalletProvider>
        </SuiClientProvider>
      <ReactQueryDevtools initialIsOpen={true} /> 
    </QueryClientProvider>
  );
}

export default SuiProviders;