//
//  CardView.swift
//  SwiftUIWallet
//
//  Created by Aman Gupta on 28/12/23.
//

import SwiftUI

struct CardView: View {
    var card: Card
    var body: some View {
        Image(card.image)
            .resizable()
            .scaledToFit()
            .overlay(
                VStack(alignment: .leading){
                    
                    Text(card.number)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    HStack{
                        Text("Valid thru")
                            .font(.footnote)
                        Text(card.expiryDate)
                            .font(.footnote)
                    }
                    
                }
                    .foregroundColor(.white)
                    .padding(.leading,25)
                    .padding(.bottom, 20)
                ,alignment:.bottomLeading
            )
            .shadow(color: .gray, radius: 1.0, x:0.0, y: 1.0)
        
        
           
        
    }
}

//#Preview {
//    ForEach(testCards){card in
//        CardView(card:card)
//            .previewDisplayName(card.type.rawValue)
//        
//        
//    }


struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(testCards) { card in
            CardView(card: card).previewDisplayName(card.type.rawValue)
        }
    }
}
