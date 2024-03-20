'use client';

import { useSignAndExecuteTransactionBlock } from '@mysten/dapp-kit';
import { useCurrentAccount, useSignTransactionBlock } from '@mysten/dapp-kit';
import { TransactionBlock } from '@mysten/sui.js/transactions';

import { useState } from 'react';
import Link from 'next/link';
import { SUI_CLOCK_OBJECT_ID } from '@mysten/sui.js/utils';

import * as z from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { SelectValue, SelectTrigger, SelectContent, SelectItem, Select } from "@/components/ui/select";

const formSchema = z
  .object({
    warlordname: z.string().min(1, { message: "Minimum 1 character" }).max(64, { message: "Maximum 64 characters" }),    
  })  

export default function Hall() {
  const currentAcc = useCurrentAccount();
  const { mutate: signAndExecuteTransactionBlock } = useSignAndExecuteTransactionBlock();
  const [digest, setDigest] = useState<string | null>(null);

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      warlordname: "Warlord",
    },
  });

  const handleSubmit = (values: z.infer<typeof formSchema>) => {
    console.log({ values });
    mint(values.warlordname)    
  };

  const mint = async (warlordname: String) => {
    try {
      
      const txb = new TransactionBlock();
      const [coin] = txb.splitCoins(txb.gas, [txb.pure(5000000000)]);           
      
      txb.moveCall({
        /* arguments: name, payment, clock */
        target: `${process.env.NEXT_PUBLIC_PACKAGE_PID}::warlord::warlord_mint`,
        arguments: [txb.pure(warlordname), coin, txb.object(SUI_CLOCK_OBJECT_ID)]
      });

      const response = await signAndExecuteTransactionBlock(
        {
          transactionBlock: txb,
          options: {
            showEffects: true,
            showBalanceChanges: true,
            showEvents: true,
          },
        },
        {
          onSuccess: (result) => {
            console.log(result);
            setDigest(result.digest);
          },
        }
      );
      console.log(response);
    } catch (error) {
      console.error(error);
    }
  }; 
  
  return (
    <>
      <main>
        <div className="flex h-[calc(100vh-104px)] flex-row justify-between px-4">
          <div className="flex w-1/4 rounded-xl border-4 border-black">
            <Form {...form}>
              <form
                onSubmit={form.handleSubmit(handleSubmit)}
                className="flex flex-col w-full gap-4 place-items-center"
              >
                <FormField
                  control={form.control}
                  name="warlordname"
                  render={({ field }) => {
                    return (
                      <FormItem>
                        <FormLabel>Warlord Name</FormLabel>
                        <FormControl>
                          <Input
                            placeholder="Warlord Name"
                            type="string"
                            {...field}
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    );
                  }}
                />
                <Button type="submit" className="w-full">
                  Mint your Warlord
                </Button>
              </form>
            </Form>    

            {digest && (
              <div className="mt-[5%]">
                <Link
                  href={`https://testnet.suivision.xyz/txblock/${digest}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="hover:bg-[#2A4361] bg-[#0084AD] text-white font-bold py-2 px-8 rounded focus:outline-none focus:shadow-outline"
                >
                  View on Explorer
                </Link>
              </div>
            )}          
          </div>
              
          <div className="flex w-1/4 rounded-xl border-4 border-black">
            
          </div>    

          <div className="flex w-1/4 rounded-xl border-4 border-black">

          </div>



        </div>     
      </main>
    </>
  );
}