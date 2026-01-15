import Testing
import Foundation

@testable import Pager
@testable import Networking

struct MockPageableResponse: Pageable, Codable, Equatable {
  let value: String
  let totalPages: UInt
}

struct PagerTests {
  @Test
  func testInitialState() async {
      // Given
      let mockClient = MockHttpClient()
      let pager = Pager(httpClient: mockClient)

      // Then
      let currentPage = await pager.currentPage
      let totalPages = await pager.totalPages
      let hasMorePages = await pager.hasMorePages

    #expect(currentPage == 0)
    #expect(totalPages == nil)
    #expect(hasMorePages) // Should be true when totalPages is unknown
  }

  @Test
  func testFirstPageFetchesPageOne() async throws {
    // Given
    let mockClient = MockHttpClient()
    let pager = Pager(httpClient: mockClient)
    let request = MockPageableHttpRequest()

    let mockResponse1 = MockPageableResponse(value: "page1", totalPages: 5)
    let mockResponse2 = MockPageableResponse(value: "page2", totalPages: 5)
    let encoder = JSONEncoder()
    mockClient.mockResponses[1] = try encoder.encode(mockResponse1)
    mockClient.mockResponses[2] = try encoder.encode(mockResponse2)

    // When
    let _: MockPageableResponse? = try await pager.nextPage(request: request)
    let _: MockPageableResponse? = try await pager.nextPage(request: request)
    #expect(await pager.currentPage == 2)

    let result: MockPageableResponse? = try await pager.firstPage(request: request)
    #expect(result != nil)
    #expect(result == mockResponse1)
    #expect(await pager.currentPage == 1)
    #expect(await pager.totalPages == 5)
  }

  @Test
  func testNextPageFetchesSequentialPages() async throws {
    // Given
    let mockClient = MockHttpClient()
    let pager = Pager(httpClient: mockClient)
    let request = MockPageableHttpRequest()

    let mockResponse1 = MockPageableResponse(value: "page1", totalPages: 3)
    let mockResponse2 = MockPageableResponse(value: "page2", totalPages: 3)
    let mockResponse3 = MockPageableResponse(value: "page3", totalPages: 3)
    let encoder = JSONEncoder()
    mockClient.mockResponses[1] = try encoder.encode(mockResponse1)
    mockClient.mockResponses[2] = try encoder.encode(mockResponse2)
    mockClient.mockResponses[3] = try encoder.encode(mockResponse3)

    // When
    let firstPage: MockPageableResponse? = try await pager.nextPage(request: request)
    #expect(await pager.currentPage == 1)

    let secondPage: MockPageableResponse? = try await pager.nextPage(request: request)
    #expect(await pager.currentPage == 2)

    let thirdPage: MockPageableResponse? = try await pager.nextPage(request: request)
    #expect(await pager.currentPage == 3)

    let noPage: MockPageableResponse? = try await pager.nextPage(request: request)
    #expect(await pager.currentPage == 3)

    // Then
    #expect(mockClient.fetchedPages == [1, 2, 3])
    #expect(firstPage == mockResponse1)
    #expect(secondPage == mockResponse2)
    #expect(thirdPage == mockResponse3)
    #expect(noPage == nil)
  }

  @Test
  func testHasMorePagesReturnsTrueWhenPagesRemain() async throws {
    let mockClient = MockHttpClient()
    let pager = Pager(httpClient: mockClient)
    let request = MockPageableHttpRequest()

    let mockResponse1 = MockPageableResponse(value: "page1", totalPages: 2)
    let mockResponse2 = MockPageableResponse(value: "page2", totalPages: 2)
    let encoder = JSONEncoder()
    mockClient.mockResponses[1] = try encoder.encode(mockResponse1)
    mockClient.mockResponses[2] = try encoder.encode(mockResponse2)

    let _: MockPageableResponse? = try await pager.firstPage(request: request)
    #expect(await pager.hasMorePages)

    let _: MockPageableResponse? = try await pager.nextPage(request: request)
    #expect(await pager.hasMorePages == false)
  }
}
