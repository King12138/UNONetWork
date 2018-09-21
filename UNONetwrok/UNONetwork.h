//
//  UNONetwork.h
//
//  
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

#ifndef _UNONETWORK_
    #define _UNONETWORK_

#if __has_include(<UNONetwork/UNONetwork.h>)

    FOUNDATION_EXPORT double UNONetworkVersionNumber;
    FOUNDATION_EXPORT const unsigned char UNONetworkVersionString[];

    #import <UNONetwork/UNORequest.h>
    #import <UNONetwork/UNOBaseRequest.h>
    #import <UNONetwork/UNONetworkAgent.h>
    #import <UNONetwork/UNOBatchRequest.h>
    #import <UNONetwork/UNOBatchRequestAgent.h>
    #import <UNONetwork/UNOChainRequest.h>
    #import <UNONetwork/UNOChainRequestAgent.h>
    #import <UNONetwork/UNONetworkConfig.h>
    #import <UNONetwork/UNOPostRequest.h>
    #import <UNONetwork/UNOGetRequest.h>
#else

    #import "UNORequest.h"
    #import "UNOBaseRequest.h"
    #import "UNONetworkAgent.h"
    #import "UNOBatchRequest.h"
    #import "UNOBatchRequestAgent.h"
    #import "UNOChainRequest.h"
    #import "UNOChainRequestAgent.h"
    #import "UNONetworkConfig.h"
    #import "UNOPostRequest.h"
    #import "UNOGetRequest.h"

#endif /* __has_include */

#endif /* _UNONETWORK_ */
