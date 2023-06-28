//
//  Menu.ControlView.swift
//  Bitsy
//
//  Created by PEXAVC on 6/26/23.
//

import Foundation
import Granite
import MarbleKit
import SwiftUI

extension Menu {
    static var controlsHeight: CGFloat {
        55 + 16
    }
    
    var controlView: some View {
        HStack(spacing: 16) {
            Button {
                center.toggleEditStream.send()
            } label: {
                Image(systemName: state.showUsernameEntry ? "arrow.backward.square" : "square.and.pencil")
                    .font(.title.bold())
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.75))
            )
            
            Spacer()
            
            HStack(spacing: 16) {
                Button {
                    center.control.send(Menu.Control.Meta(control: .clip))
                } label: {
                    Image(systemName: "scissors")
                        .font(.title3.bold())
                        .frame(width: 24)
                        .foregroundColor(.white)
                        .padding(.top, 2)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 8)
                
                Button {
                    center.control.send(Menu.Control.Meta(control: .toggleFX))
                } label: {
                    Image(systemName: "fx")
                        .font(.title3.bold())
                        .frame(width: 24)
                        .foregroundColor(state.fxEnabled ? .black : .white)
                        .padding(4)
                }
                .buttonStyle(PlainButtonStyle())
                .background(
                    RoundedRectangle(cornerRadius: 4.0)
                        .stroke(.white, lineWidth: 2.0)
                        .background(state.fxEnabled ? .white : .clear)
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.75))
            )
            
            Spacer()
            
            Button {
                center.reset.send()
            } label: {
                Image(systemName: "arrow.counterclockwise.circle")
                    .font(.title.bold())
                    .frame(width: 24)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.75))
            )
        }
    }
    
    var fxView: some View {
        ScrollView([.horizontal], showsIndicators: false) {
            HStack {
                ForEach(MarbleEffect.effects2D, id: \.self) { effect in
                    
                    Button {
                        center.control.send(Menu.Control.Meta(control: .modifyFX(effect)))
                    } label: {
                        Text("\(effect.rawValue)")
                            .font(.title3.bold())
                            .foregroundColor(state.fx.contains(effect) ? .white : .black)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 4.0)
                            .fill(state.fx.contains(effect) ? .black : .white)
                    )
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: 300)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 8.0)
                .fill(.white)
        )
    }
}
