//
//  WalletView.swift
//  SwiftUIWallet
//
//  Created by Aman Gupta on 28/12/23.
//

import SwiftUI

struct WalletView: View {
    @State var cards:[Card] = testCards
    
//    private func zIndex(card: Card)-> Double{
//        guard let cardIndex = index(card:card) else {
//            return 0.0
//        }
//        return -Double(cardIndex)
//    }
    
    private func zIndex(card: Card)-> Double{
        guard let cardIndex = index(card: card) else{
            return 0.0
        }
        let defaultZIndex = -Double(cardIndex)
        if let draggingIndex = dragState.index,
           cardIndex == draggingIndex{
            return defaultZIndex + Double(dragState.translation.height / Self.cardOffset)
        }
        
        return defaultZIndex
            
    }
    
    private func index(card: Card)-> Int?{
        guard let index = cards.firstIndex(where:{$0.id == card.id}) else{
            return nil
        }
        return index
        
    }
    
    private static let cardOffset: CGFloat = 50.0
    
    //    private func offset(card: Card)-> CGSize{
    //        guard let cardIndex = index(card: card) else{
    //            return CGSize()
    //        }
    //        return CGSize(width: 0, height: -50 * CGFloat(cardIndex))
    //    }
    //
    private func offset(card: Card)-> CGSize{
        guard let cardIndex = index(card: card) else{
            return CGSize()
            
        }
        if isCardPressed{
            guard let selectedCard = self.selectedCard,
                  let selectedCardIndex = index(card: selectedCard) else{
                return .zero
                
            }
            if cardIndex >= selectedCardIndex{
                return .zero
            }
            let offset = CGSize(width: 0, height: 1400)
            return offset
            
        }
        
        //Handle Dragging
        var pressedOffset = CGSize.zero
        var dragOffsetY: CGFloat = 0.0
        
        if let draggingIndex = dragState.index,
           cardIndex == draggingIndex{
            pressedOffset.height = dragState.isPressing ? -20 : 0
            
            switch dragState.translation.width {
            case let width where width < -10: pressedOffset.width = -20
            case let width where width > 10: pressedOffset.width = 20
            default: break
                
            }
            dragOffsetY = dragState.translation.height
            
        }
        
        
        return CGSize(width: 0, height: -50 * CGFloat(cardIndex) + pressedOffset.height + dragOffsetY)
    }
    
    
    @State private var isCardPresented = false
    private func transitionAnimation(card: Card)-> Animation{
        var delay = 0.0
        
        if let index = index(card: card){
            delay = Double(cards.count - index) * 0.1
            
        }
        return Animation.spring(response: 0.1, dampingFraction: 0.8, blendDuration: 0.02).delay(delay)
        
        
    }
    
    @State var isCardPressed = false
    @State var selectedCard: Card?
    
    @GestureState private var dragState = DragState.inactive
    
    private func rearrangeCards(with card: Card, dragOffset: CGSize){
        guard let draggingCardIndex = index(card: card) else{
            return
        }
        
        var newIndex = draggingCardIndex + Int(-dragOffset.height / Self.cardOffset)
        newIndex = newIndex >= cards.count ? cards.count - 1: newIndex
        newIndex = newIndex < 0 ? 0 : newIndex
        
        let removedCard = cards.remove(at: draggingCardIndex)
        cards.insert(removedCard, at: newIndex)
    }
    
    var body: some View {
        TopNavBar()
            .padding(.bottom)
        
        Spacer()
        ZStack{
            ForEach(cards){ card in
                CardView(card: card)
                    .padding(.horizontal,35)
                    .offset(self.offset(card:card))
                    .zIndex(self.zIndex(card: card))
                    .id(isCardPresented)
                    .transition(AnyTransition.slide.combined(with: .move(edge: .leading)).combined(with:.opacity))
                    .animation(self.transitionAnimation(card: card), value: isCardPresented)
                    .gesture(
                        TapGesture()
                            .onEnded({ _ in
                                withAnimation(.easeOut(duration: 0.15).delay(0.1)){
                                    self.isCardPressed.toggle()
                                    self.selectedCard = self.isCardPressed ? card : nil
                                }
                                
                            })
                            .exclusively(before: LongPressGesture(minimumDuration: 0.05)
                                .sequenced(before: DragGesture())
                                .updating(self.$dragState, body: { (value, state, transaction) in
                                    switch value {
                                    case .first(true):
                                        state = .pressing(index: self.index(card: card))
                                    case .second(true, let drag):
                                        state = .dragging(index: self.index(card: card), translation: drag? .translation ?? .zero)
                                    default:
                                        break
                                    } })
                                    .onEnded({ (value) in
                                        guard case .second(true, let drag?) = value else{
                                            return
                                        }
                                        withAnimation(.spring()){
                                            self.rearrangeCards(with: card, dragOffset: drag.translation)
                                        }
                                        
                                    })
                                         
                                         
                            )
                        
                    )
                
            }.onAppear{
                isCardPresented.toggle()
            }
            
            if isCardPressed{
                TransactionHistoryView(transactions: testTransactions)
                    .padding(.top, 10)
                    .transition(.move(edge: .bottom))
            }
            
        }
        
    }
}
    

#Preview {
    WalletView()
}

struct TopNavBar: View{
    var body: some View{
        HStack{
            Text("Wallet")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.heavy)
            Spacer()
            Image(systemName: "plus.circle.fill")
                .font(.system(.title))
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}


enum DragState{
    case inactive
    case pressing(index: Int? = nil)
    case dragging(index: Int? = nil, translation: CGSize)
    
    var index: Int?{
        switch self{
        case .pressing(let index), .dragging(let index, _):
            return index
        case .inactive:
            return nil
        }
    }
    
    var translation: CGSize{
        switch self{
        case .inactive, .pressing:
            return .zero
        case .dragging( _ ,let translation):
            return translation
            
        }
        
    }
    
    var isPressing: Bool{
        switch self{
        case .pressing, .dragging:
            return true
        case .inactive:
            return false
            
        }
    }
    
    var isDragging: Bool{
        switch self{
        case .dragging:
            return true
        case .inactive, .pressing:
            return false
        }
        
    }
    
    
    
    
    
    
}
