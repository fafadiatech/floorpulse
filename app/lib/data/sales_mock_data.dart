import '../models/app_user.dart';
import '../models/customer.dart';
import '../models/customer_visit.dart';
import '../models/sales_approval.dart';
import '../models/sales_memo.dart';
import '../models/sales_order.dart';

class SalesMockData {
  // ── User ────────────────────────────────────────────────────────────────────

  static const AppUser salesUser = AppUser(
    username: 'sales',
    name: 'Priya Sharma',
    userRole: UserRole.sales,
    roleLabel: 'Sales Executive',
    employeeId: 'EMP-5001',
    department: 'Sales & Distribution',
    initials: 'PS',
  );

  // ── Dashboard Stats ──────────────────────────────────────────────────────────

  static const Map<String, dynamic> dashboardStats = {
    'todayVisits': 3,
    'pendingApprovals': 3,
    'openOrders': 6,
    'collectionMTD': 435000.0,
    'targetMTD': 800000.0,
  };

  // ── Customers ─────────────────────────────────────────────────────────────────

  static final List<Customer> customers = [
    Customer(
      id: 'c1',
      name: 'Bharat Pumps & Valves',
      code: 'BPV-001',
      contactPerson: 'Rajesh Mehta',
      phone: '+91 98200 11234',
      email: 'rajesh@bharatpumps.com',
      address: 'Plot 14, MIDC Ambad',
      city: 'Nashik',
      gstin: '27AABCB1234F1ZV',
      segment: 'Dealer',
      outstandingBalance: 248500,
      creditLimit: 500000,
      paymentTerms: 'Net 45',
      status: CustomerStatus.active,
      lastVisitDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Customer(
      id: 'c2',
      name: 'Hydro Systems Ltd.',
      code: 'HSL-002',
      contactPerson: 'Anand Kulkarni',
      phone: '+91 98765 43210',
      email: 'anand@hydrosys.in',
      address: 'C-22 TTC Industrial Area',
      city: 'Navi Mumbai',
      gstin: '27AAACH5678G1ZM',
      segment: 'Distributor',
      outstandingBalance: 120000,
      creditLimit: 300000,
      paymentTerms: 'Net 30',
      status: CustomerStatus.active,
      lastVisitDate: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Customer(
      id: 'c3',
      name: 'Industrial Fluid Co.',
      code: 'IFC-003',
      contactPerson: 'Suresh Patil',
      phone: '+91 99887 76655',
      email: 'suresh@industrialfluid.co.in',
      address: 'Survey 45, Ranjangaon',
      city: 'Pune',
      gstin: '27AAACI9012H1ZK',
      segment: 'Direct',
      outstandingBalance: 482000,
      creditLimit: 400000,
      paymentTerms: 'Net 60',
      status: CustomerStatus.onHold,
      lastVisitDate: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Customer(
      id: 'c4',
      name: 'Apex Engineering Works',
      code: 'AEW-004',
      contactPerson: 'Vinod Joshi',
      phone: '+91 90000 55566',
      email: 'vinod@apexengg.com',
      address: 'B-5 Waluj MIDC',
      city: 'Aurangabad',
      gstin: '27AAACA3456I1ZN',
      segment: 'Dealer',
      outstandingBalance: 79500,
      creditLimit: 200000,
      paymentTerms: 'Net 30',
      status: CustomerStatus.active,
      lastVisitDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Customer(
      id: 'c5',
      name: 'National Hydraulics Pvt. Ltd.',
      code: 'NHL-005',
      contactPerson: 'Deepa Rao',
      phone: '+91 91234 56789',
      email: 'deepa@nationalhydro.in',
      address: 'E-12 Butibori MIDC',
      city: 'Nagpur',
      gstin: '27AAACN7890J1ZL',
      segment: 'Distributor',
      outstandingBalance: 34800,
      creditLimit: 150000,
      paymentTerms: 'Net 30',
      status: CustomerStatus.active,
      lastVisitDate: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Customer(
      id: 'c6',
      name: 'Sigma Flow Technologies',
      code: 'SFT-006',
      contactPerson: 'Kiran Deshmukh',
      phone: '+91 88001 22334',
      email: 'kiran@sigmaflow.com',
      address: 'Plot 7, Chakan MIDC',
      city: 'Pune',
      gstin: '27AAACS2345K1ZP',
      segment: 'Direct',
      outstandingBalance: 0,
      creditLimit: 100000,
      paymentTerms: 'Advance',
      status: CustomerStatus.active,
      lastVisitDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  // ── Ledger Entries (per customer, keyed by customerId) ────────────────────────

  static final Map<String, List<LedgerEntry>> customerLedgers = {
    'c1': [
      const LedgerEntry(
        date: '01 Jun 2024',
        type: 'Invoice',
        reference: 'INV-2024-201',
        amount: 150000,
        balance: 150000,
        invoiceId: 'inv1',
      ),
      const LedgerEntry(
        date: '15 Jun 2024',
        type: 'Payment',
        reference: 'PAY-2024-088',
        amount: -100000,
        balance: 50000,
      ),
      const LedgerEntry(
        date: '20 Jun 2024',
        type: 'Invoice',
        reference: 'INV-2024-215',
        amount: 98500,
        balance: 148500,
        invoiceId: 'inv2',
      ),
      const LedgerEntry(
        date: '05 Jul 2024',
        type: 'Invoice',
        reference: 'INV-2024-228',
        amount: 100000,
        balance: 248500,
        invoiceId: 'inv3',
      ),
    ],
    'c2': [
      const LedgerEntry(
        date: '10 Jun 2024',
        type: 'Invoice',
        reference: 'INV-2024-205',
        amount: 200000,
        balance: 200000,
        invoiceId: 'inv4',
      ),
      const LedgerEntry(
        date: '30 Jun 2024',
        type: 'Payment',
        reference: 'PAY-2024-095',
        amount: -80000,
        balance: 120000,
      ),
    ],
    'c3': [
      const LedgerEntry(
        date: '15 May 2024',
        type: 'Invoice',
        reference: 'INV-2024-180',
        amount: 250000,
        balance: 250000,
        invoiceId: 'inv5',
      ),
      const LedgerEntry(
        date: '01 Jun 2024',
        type: 'Invoice',
        reference: 'INV-2024-195',
        amount: 232000,
        balance: 482000,
        invoiceId: 'inv6',
      ),
    ],
    'c4': [
      const LedgerEntry(
        date: '25 Jun 2024',
        type: 'Invoice',
        reference: 'INV-2024-222',
        amount: 79500,
        balance: 79500,
        invoiceId: 'inv7',
      ),
    ],
    'c5': [
      const LedgerEntry(
        date: '10 Jul 2024',
        type: 'Invoice',
        reference: 'INV-2024-235',
        amount: 34800,
        balance: 34800,
        invoiceId: 'inv8',
      ),
    ],
  };

  // ── Invoices (simplified, keyed by invoiceId) ─────────────────────────────────

  static final Map<String, Map<String, dynamic>> invoices = {
    'inv1': {
      'invoiceId': 'inv1',
      'reference': 'INV-2024-201',
      'date': '01 Jun 2024',
      'dueDate': '16 Jul 2024',
      'amount': 150000.0,
      'paid': 100000.0,
      'status': 'Partial',
      'soNumber': 'SO-2024-087',
      'lines': [
        {
          'description': 'Hydraulic Pump Assembly HPA-2000',
          'qty': 5.0,
          'rate': 28000.0,
          'amount': 140000.0,
        },
        {
          'description': 'Freight & Packaging',
          'qty': 1.0,
          'rate': 10000.0,
          'amount': 10000.0,
        },
      ],
    },
    'inv2': {
      'invoiceId': 'inv2',
      'reference': 'INV-2024-215',
      'date': '20 Jun 2024',
      'dueDate': '04 Aug 2024',
      'amount': 98500.0,
      'paid': 0.0,
      'status': 'Unpaid',
      'soNumber': 'SO-2024-089',
      'lines': [
        {
          'description': 'Control Valve Assembly CVA-500',
          'qty': 3.0,
          'rate': 32000.0,
          'amount': 96000.0,
        },
        {
          'description': 'Documentation',
          'qty': 1.0,
          'rate': 2500.0,
          'amount': 2500.0,
        },
      ],
    },
    'inv3': {
      'invoiceId': 'inv3',
      'reference': 'INV-2024-228',
      'date': '05 Jul 2024',
      'dueDate': '19 Aug 2024',
      'amount': 100000.0,
      'paid': 0.0,
      'status': 'Unpaid',
      'soNumber': 'SO-2024-089',
      'lines': [
        {
          'description': 'Hydraulic Pump Assembly HPA-2000',
          'qty': 3.0,
          'rate': 28000.0,
          'amount': 84000.0,
        },
        {
          'description': 'Spare Seal Kit',
          'qty': 8.0,
          'rate': 2000.0,
          'amount': 16000.0,
        },
      ],
    },
  };

  // ── Sales Orders ──────────────────────────────────────────────────────────────

  static final List<SalesOrder> salesOrders = [
    SalesOrder(
      id: 'so1',
      soNumber: 'SO-2024-089',
      customerId: 'c1',
      customerName: 'Bharat Pumps & Valves',
      orderDate: DateTime.now().subtract(const Duration(days: 12)),
      expectedDelivery: DateTime.now().add(const Duration(days: 5)),
      status: SOStatus.inProduction,
      totalAmount: 198500,
      paidAmount: 0,
      paymentTerms: 'Net 45',
      deliveryAddress: 'Plot 14, MIDC Ambad, Nashik – 422010',
      workOrderRef: 'WO-2024-041',
      lines: const [
        SOLine(
          lineNo: '1',
          itemCode: 'FG-HPA-2000',
          description: 'Hydraulic Pump Assembly HPA-2000',
          qty: 3,
          unit: 'Nos',
          rate: 28000,
          fulfillmentStatus: 'In Production',
        ),
        SOLine(
          lineNo: '2',
          itemCode: 'FG-CVA-500',
          description: 'Control Valve Assembly CVA-500',
          qty: 2,
          unit: 'Nos',
          rate: 32000,
          fulfillmentStatus: 'Pending',
        ),
        SOLine(
          lineNo: '3',
          itemCode: 'SP-SEAL-KIT',
          description: 'Spare Seal Kit',
          qty: 6,
          unit: 'Kits',
          rate: 2000,
          discount: 5,
          fulfillmentStatus: 'Ready',
        ),
      ],
      payments: const [],
    ),
    SalesOrder(
      id: 'so2',
      soNumber: 'SO-2024-088',
      customerId: 'c2',
      customerName: 'Hydro Systems Ltd.',
      orderDate: DateTime.now().subtract(const Duration(days: 18)),
      expectedDelivery: DateTime.now().add(const Duration(days: 2)),
      status: SOStatus.dispatched,
      totalAmount: 200000,
      paidAmount: 80000,
      paymentTerms: 'Net 30',
      deliveryAddress: 'C-22 TTC Industrial Area, Navi Mumbai – 400710',
      workOrderRef: 'WO-2024-039',
      lines: const [
        SOLine(
          lineNo: '1',
          itemCode: 'FG-HPA-2000',
          description: 'Hydraulic Pump Assembly HPA-2000',
          qty: 2,
          unit: 'Nos',
          rate: 28000,
          fulfillmentStatus: 'Dispatched',
        ),
        SOLine(
          lineNo: '2',
          itemCode: 'SP-SEAL-KIT',
          description: 'Spare Seal Kit',
          qty: 4,
          unit: 'Kits',
          rate: 2000,
          fulfillmentStatus: 'Dispatched',
        ),
        SOLine(
          lineNo: '3',
          itemCode: 'DOC-WC',
          description: 'Warranty Card & Manuals',
          qty: 2,
          unit: 'Sets',
          rate: 1000,
          fulfillmentStatus: 'Dispatched',
        ),
      ],
      payments: const [
        SalesPaymentEntry(
          date: '15 Jun 2024',
          mode: 'NEFT',
          reference: 'NEFT2024061501',
          amount: 80000,
          status: 'Cleared',
        ),
      ],
    ),
    SalesOrder(
      id: 'so3',
      soNumber: 'SO-2024-087',
      customerId: 'c1',
      customerName: 'Bharat Pumps & Valves',
      orderDate: DateTime.now().subtract(const Duration(days: 30)),
      expectedDelivery: DateTime.now().subtract(const Duration(days: 5)),
      status: SOStatus.delivered,
      totalAmount: 150000,
      paidAmount: 100000,
      paymentTerms: 'Net 45',
      deliveryAddress: 'Plot 14, MIDC Ambad, Nashik – 422010',
      lines: const [
        SOLine(
          lineNo: '1',
          itemCode: 'FG-HPA-2000',
          description: 'Hydraulic Pump Assembly HPA-2000',
          qty: 5,
          unit: 'Nos',
          rate: 28000,
          fulfillmentStatus: 'Dispatched',
        ),
        SOLine(
          lineNo: '2',
          itemCode: 'DOC-WC',
          description: 'Warranty Card & Manuals',
          qty: 5,
          unit: 'Sets',
          rate: 1000,
          fulfillmentStatus: 'Dispatched',
        ),
      ],
      payments: const [
        SalesPaymentEntry(
          date: '01 Jul 2024',
          mode: 'Cheque',
          reference: 'CHQ-00445',
          amount: 100000,
          status: 'Cleared',
        ),
      ],
    ),
    SalesOrder(
      id: 'so4',
      soNumber: 'SO-2024-086',
      customerId: 'c4',
      customerName: 'Apex Engineering Works',
      orderDate: DateTime.now().subtract(const Duration(days: 10)),
      expectedDelivery: DateTime.now().add(const Duration(days: 8)),
      status: SOStatus.confirmed,
      totalAmount: 79500,
      paidAmount: 0,
      paymentTerms: 'Net 30',
      deliveryAddress: 'B-5 Waluj MIDC, Aurangabad – 431136',
      lines: const [
        SOLine(
          lineNo: '1',
          itemCode: 'FG-CVA-500',
          description: 'Control Valve Assembly CVA-500',
          qty: 2,
          unit: 'Nos',
          rate: 32000,
          fulfillmentStatus: 'Pending',
        ),
        SOLine(
          lineNo: '2',
          itemCode: 'SP-FILTER',
          description: 'Return Line Filter',
          qty: 5,
          unit: 'Nos',
          rate: 3000,
          discount: 10,
          fulfillmentStatus: 'Ready',
        ),
      ],
      payments: const [],
    ),
    SalesOrder(
      id: 'so5',
      soNumber: 'SO-2024-085',
      customerId: 'c5',
      customerName: 'National Hydraulics Pvt. Ltd.',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      expectedDelivery: DateTime.now().add(const Duration(days: 15)),
      status: SOStatus.confirmed,
      totalAmount: 34800,
      paidAmount: 0,
      paymentTerms: 'Net 30',
      deliveryAddress: 'E-12 Butibori MIDC, Nagpur – 441122',
      lines: const [
        SOLine(
          lineNo: '1',
          itemCode: 'FG-HPA-2000',
          description: 'Hydraulic Pump Assembly HPA-2000',
          qty: 1,
          unit: 'Nos',
          rate: 28000,
          fulfillmentStatus: 'Pending',
        ),
        SOLine(
          lineNo: '2',
          itemCode: 'SP-SEAL-KIT',
          description: 'Spare Seal Kit',
          qty: 2,
          unit: 'Kits',
          rate: 2000,
          discount: 5,
          fulfillmentStatus: 'Ready',
        ),
        SOLine(
          lineNo: '3',
          itemCode: 'DOC-WC',
          description: 'Warranty Card & Manuals',
          qty: 1,
          unit: 'Sets',
          rate: 1000,
          fulfillmentStatus: 'Pending',
        ),
      ],
      payments: const [],
    ),
    SalesOrder(
      id: 'so6',
      soNumber: 'SO-2024-084',
      customerId: 'c6',
      customerName: 'Sigma Flow Technologies',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      expectedDelivery: DateTime.now().add(const Duration(days: 20)),
      status: SOStatus.draft,
      totalAmount: 56000,
      paidAmount: 56000,
      paymentTerms: 'Advance',
      deliveryAddress: 'Plot 7, Chakan MIDC, Pune – 410501',
      lines: const [
        SOLine(
          lineNo: '1',
          itemCode: 'FG-HPA-2000',
          description: 'Hydraulic Pump Assembly HPA-2000',
          qty: 2,
          unit: 'Nos',
          rate: 28000,
          fulfillmentStatus: 'Pending',
        ),
      ],
      payments: const [
        SalesPaymentEntry(
          date: '15 Jul 2024',
          mode: 'UPI',
          reference: 'UPI20240715SFT',
          amount: 56000,
          status: 'Cleared',
        ),
      ],
    ),
  ];

  // ── Approvals ─────────────────────────────────────────────────────────────────

  static final List<SalesApproval> approvals = [
    SalesApproval(
      id: 'ap1',
      type: ApprovalType.creditLimitOverride,
      title: 'Credit Limit Override',
      customerId: 'c1',
      customerName: 'Bharat Pumps & Valves',
      soNumber: 'SO-2024-089',
      requestedBy: 'Priya Sharma',
      requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
      requestedValue: 550000,
      details:
          'Customer outstanding ₹2.48L. New order SO-2024-089 worth ₹1.98L would breach ₹5L credit limit. Requesting temporary limit increase to ₹5.5L.',
      status: ApprovalStatus.pending,
    ),
    SalesApproval(
      id: 'ap2',
      type: ApprovalType.discountOverride,
      title: 'Discount Approval – 12%',
      customerId: 'c2',
      customerName: 'Hydro Systems Ltd.',
      soNumber: 'SO-2024-088',
      requestedBy: 'Priya Sharma',
      requestedAt: DateTime.now().subtract(const Duration(hours: 5)),
      requestedValue: 12,
      details:
          'Customer is placing a repeat order of ₹2L. Requesting 12% discount (standard max: 8%) to retain business against competitor pricing.',
      status: ApprovalStatus.pending,
    ),
    SalesApproval(
      id: 'ap3',
      type: ApprovalType.specialTerm,
      title: 'Extended Credit – Net 75',
      customerId: 'c3',
      customerName: 'Industrial Fluid Co.',
      requestedBy: 'Priya Sharma',
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
      requestedValue: 75,
      details:
          'Customer requests Net 75 days (standard: Net 60) for next 2 orders due to seasonal cashflow pressure. Willing to increase order volume by 30%.',
      status: ApprovalStatus.pending,
    ),
    SalesApproval(
      id: 'ap4',
      type: ApprovalType.discountOverride,
      title: 'Discount Approval – 10%',
      customerId: 'c4',
      customerName: 'Apex Engineering Works',
      soNumber: 'SO-2024-086',
      requestedBy: 'Priya Sharma',
      requestedAt: DateTime.now().subtract(const Duration(days: 3)),
      requestedValue: 10,
      approvedValue: 8,
      details:
          'Requested 10% discount. Approved at 8% by Regional Sales Manager.',
      status: ApprovalStatus.approved,
      remarks:
          'Approved at 8% only. Do not exceed this for this customer segment.',
    ),
  ];

  // ── Today's Visits ────────────────────────────────────────────────────────────

  static final List<CustomerVisit> todayVisits = [
    CustomerVisit(
      id: 'v1',
      customerId: 'c1',
      customerName: 'Bharat Pumps & Valves',
      city: 'Nashik',
      scheduledAt: DateTime.now().copyWith(hour: 10, minute: 30),
      purpose: 'Order follow-up & SO-2024-089 review',
      status: VisitStatus.completed,
      checkInTime: DateTime.now().copyWith(hour: 10, minute: 35),
      checkOutTime: DateTime.now().copyWith(hour: 11, minute: 45),
      notes:
          'Customer satisfied with production timeline. Expecting dispatch by 22nd.',
      outcome: 'Follow-up Required',
    ),
    CustomerVisit(
      id: 'v2',
      customerId: 'c4',
      customerName: 'Apex Engineering Works',
      city: 'Aurangabad',
      scheduledAt: DateTime.now().copyWith(hour: 14, minute: 0),
      purpose: 'New product demo – HPA-3000 series',
      status: VisitStatus.checkedIn,
      checkInTime: DateTime.now().copyWith(hour: 14, minute: 8),
    ),
    CustomerVisit(
      id: 'v3',
      customerId: 'c5',
      customerName: 'National Hydraulics Pvt. Ltd.',
      city: 'Nagpur',
      scheduledAt: DateTime.now().copyWith(hour: 16, minute: 30),
      purpose: 'Payment collection & new enquiry',
      status: VisitStatus.scheduled,
    ),
  ];

  // ── Memos ─────────────────────────────────────────────────────────────────────

  static final List<SalesMemo> memos = [
    SalesMemo(
      id: 'm1',
      type: MemoType.voice,
      content:
          'Rajesh at Bharat Pumps mentioned they are planning to expand to a third assembly line next quarter. Will need 4-6 HPA-3000 units. Follow up in October with a formal quote.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      customerId: 'c1',
      customerName: 'Bharat Pumps & Valves',
      productInterest: 'HPA-3000',
    ),
    SalesMemo(
      id: 'm2',
      type: MemoType.note,
      content:
          'Anand from Hydro Systems mentioned competitor Flowmax is quoting CVA-500 equivalent at 15% lower. Need to justify our pricing with service advantage.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      customerId: 'c2',
      customerName: 'Hydro Systems Ltd.',
      productInterest: 'FG-CVA-500',
    ),
    SalesMemo(
      id: 'm3',
      type: MemoType.note,
      content:
          'Need to prepare Q3 quotation for Sigma Flow. They are interested in a bulk order if we can offer better payment terms.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      customerId: 'c6',
      customerName: 'Sigma Flow Technologies',
    ),
    SalesMemo(
      id: 'm4',
      type: MemoType.voice,
      content:
          'Reminder to self: check with production team on lead time for HPA-3000 before committing to any customer.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // ── Quotations (simplified for More screen) ───────────────────────────────────

  static final List<Map<String, dynamic>> quotations = [
    {
      'id': 'q1',
      'quotationNo': 'QT-2024-031',
      'customerId': 'c2',
      'customerName': 'Hydro Systems Ltd.',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'validUntil': DateTime.now().add(const Duration(days: 25)),
      'amount': 180000.0,
      'status': 'Sent',
      'items': 3,
    },
    {
      'id': 'q2',
      'quotationNo': 'QT-2024-030',
      'customerId': 'c3',
      'customerName': 'Industrial Fluid Co.',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'validUntil': DateTime.now().add(const Duration(days: 20)),
      'amount': 320000.0,
      'status': 'Under Review',
      'items': 4,
    },
    {
      'id': 'q3',
      'quotationNo': 'QT-2024-029',
      'customerId': 'c5',
      'customerName': 'National Hydraulics Pvt. Ltd.',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'validUntil': DateTime.now().add(const Duration(days: 15)),
      'amount': 95000.0,
      'status': 'Accepted',
      'items': 2,
    },
  ];

  // ── Leads (simplified for More screen) ───────────────────────────────────────

  static final List<Map<String, dynamic>> leads = [
    {
      'id': 'l1',
      'company': 'Sunrise Hydraulics Ltd.',
      'contact': 'Mohit Agarwal',
      'phone': '+91 95555 00001',
      'city': 'Pune',
      'interest': 'HPA-2000 – 3 units',
      'stage': 'Qualified',
      'createdAt': DateTime.now().subtract(const Duration(days: 4)),
    },
    {
      'id': 'l2',
      'company': 'FluidTech Solutions',
      'contact': 'Pallavi Nair',
      'phone': '+91 97777 88889',
      'city': 'Hyderabad',
      'interest': 'CVA-500 series',
      'stage': 'Contact Made',
      'createdAt': DateTime.now().subtract(const Duration(days: 8)),
    },
    {
      'id': 'l3',
      'company': 'Precision Pumps Corp.',
      'contact': 'Arjun Singh',
      'phone': '+91 88800 99911',
      'city': 'Delhi',
      'interest': 'HPA-3000 (new product)',
      'stage': 'New',
      'createdAt': DateTime.now().subtract(const Duration(days: 12)),
    },
  ];
}
