import SwiftUI

struct CommunitiesView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var selectedCommunity: Community? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Find your tribe. Discuss, share trade ideas, and learn from investors who think like you.")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.text2)
                        .lineSpacing(4)
                        .padding(.horizontal, 18)
                        .padding(.top, 10)
                        .padding(.bottom, 20)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(Array(COMMUNITIES.enumerated()), id: \.element.id) { i, community in
                            CommunityTile(community: community)
                                .staggerEntrance(index: i)
                                .onTapGesture { selectedCommunity = community }
                        }
                    }
                    .padding(.horizontal, 16)

                    Color.clear.frame(height: 60)
                }
            }
            .background(Theme.bg)
            .navigationTitle("Communities")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.text3)
                    }
                }
            }
            .sheet(item: $selectedCommunity) { community in
                CommunityDetailView(community: community)
            }
        }
    }
}

struct CommunityTile: View {
    @Environment(AppState.self) var appState
    let community: Community
    @State private var appeared = false

    var isJoined: Bool { appState.joinedCommunities.contains(community.name) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Icon header
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [community.color.opacity(0.25), community.color.opacity(0.10)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(height: 72)
                Image(systemName: community.icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(community.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(community.name)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)

                Text(community.description)
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.text3)
                    .lineLimit(2)
                    .lineSpacing(2)
                    .frame(height: 28, alignment: .top)

                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(Theme.text4)
                    Text("\(community.members.formatted())")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.text3)
                    Spacer()
                    Text("·")
                        .foregroundStyle(Theme.text4)
                    Circle()
                        .fill(Theme.gain)
                        .frame(width: 5, height: 5)
                    Text("\(community.activity24h)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.gain)
                }
                .padding(.top, 4)

                // Holdings chips
                HStack(spacing: 4) {
                    ForEach(community.topHoldings.prefix(3), id: \.self) { t in
                        Text(t)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(community.color)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(community.color.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 2)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        if isJoined {
                            appState.joinedCommunities.remove(community.name)
                        } else {
                            appState.joinedCommunities.insert(community.name)
                        }
                    }
                } label: {
                    Text(isJoined ? "Joined" : "Join")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(isJoined ? Theme.text2 : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isJoined ? Theme.bg3 : community.color)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isJoined ? Theme.border : Color.clear, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 14)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isJoined ? community.color.opacity(0.4) : Theme.border, lineWidth: isJoined ? 1.5 : 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 8, y: 3)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.92)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) { appeared = true }
        }
    }
}

struct CommunityDetailView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    let community: Community

    var isJoined: Bool { appState.joinedCommunities.contains(community.name) }

    private let mockPosts = [
        ("Alex Chen", "@alexcrypto", "Just added more NVDA — the AI infrastructure buildout is still in inning 2. These are not normal times.", "2h ago", 47),
        ("Lena V.", "@lena_invest", "SMCI up 8% today after the consolidation broke out. Next stop $900?", "4h ago", 83),
        ("Priya N.", "@priyainvests", "Anyone watching the AMD vs NVDA share battle? AMD's Mi300X is seriously eating into NVDA's data center share.", "6h ago", 31),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(LinearGradient(
                                colors: [community.color.opacity(0.3), community.color.opacity(0.05)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(height: 130)
                        VStack(spacing: 10) {
                            Image(systemName: community.icon)
                                .font(.system(size: 42, weight: .bold))
                                .foregroundStyle(community.color)
                            Text(community.name)
                                .font(.system(size: 20, weight: .black))
                                .foregroundStyle(Theme.text)
                        }
                    }
                    .padding(.bottom, 16)

                    // Stats row
                    HStack {
                        communityStatChip(Image(systemName: "person.2.fill"), "\(community.members.formatted()) members", community.color)
                        communityStatChip(Image(systemName: "bubble.left.fill"), "\(community.activity24h) posts/day", Theme.accent)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)

                    // Description
                    Text(community.description)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.text2)
                        .lineSpacing(4)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 18)

                    // Join button
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            if isJoined {
                                appState.joinedCommunities.remove(community.name)
                            } else {
                                appState.joinedCommunities.insert(community.name)
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isJoined ? "checkmark.circle.fill" : "person.fill.badge.plus")
                                .font(.system(size: 14))
                            Text(isJoined ? "Joined Community" : "Join Community")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(isJoined ? Theme.text2 : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isJoined ? Theme.card : community.color)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(isJoined ? Theme.border : Color.clear, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                    // Recent posts
                    Text("RECENT POSTS")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(2.0)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 10)

                    VStack(spacing: 10) {
                        ForEach(mockPosts, id: \.0) { post in
                            communityPostCard(name: post.0, handle: post.1, text: post.2, time: post.3, likes: post.4)
                        }
                    }
                    .padding(.horizontal, 16)

                    Color.clear.frame(height: 40)
                }
            }
            .background(Theme.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.text3)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func communityStatChip(_ icon: Image, _ text: String, _ color: Color) -> some View {
        HStack(spacing: 6) {
            icon.font(.system(size: 12)).foregroundStyle(color)
            Text(text).font(.system(size: 12, weight: .semibold)).foregroundStyle(Theme.text2)
        }
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(color.opacity(0.10))
        .clipShape(Capsule())
    }

    @ViewBuilder
    private func communityPostCard(name: String, handle: String, text: String, time: String, likes: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(community.color.opacity(0.8))
                    .frame(width: 36, height: 36)
                    .overlay(Text(String(name.prefix(1))).font(.system(size: 14, weight: .black)).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 1) {
                    Text(name).font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.text)
                    Text("\(handle) · \(time)").font(.system(size: 11)).foregroundStyle(Theme.text3)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "heart").font(.system(size: 11)).foregroundStyle(Theme.text3)
                    Text("\(likes)").font(.system(size: 11)).foregroundStyle(Theme.text3)
                }
            }
            Text(text).font(.system(size: 13)).foregroundStyle(Theme.text2).lineSpacing(3)
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }
}
