# AI-Assisted Barangay Service Request Management and Classification System

A web-based system where residents submit barangay service requests online, and barangay staff track and resolve them. The system automatically sorts each request into a category and shows the most reported community concerns.

🌐 **Live Demo:** https://Liporada-Rizza.github.io/barangay-service-request/

---

## 📌 Project Overview
Residents can register, log in, submit requests (e.g., broken streetlights, uncollected garbage, clearance requests), and track their status. Barangay staff can view all requests, search and filter them, update their status, and see AI-assisted insights about common concerns.

## ❗ Problem Statement
Many barangays still receive service requests through walk-ins, phone calls, or paper logbooks. Requests can get lost, residents cannot track progress, and staff have no quick way to see which concerns are reported most often.

## 🎯 Objectives
- Allow residents to submit and track service requests online
- Help barangay staff manage requests in one place
- Automatically categorize requests to save staff time
- Summarize the most reported concerns to support decision-making
- Protect user data with secure login and access rules

## 👥 Target Users
| User | Description |
|---|---|
| **Resident** | Submits and tracks their own requests |
| **Barangay Staff (Admin)** | Manages all requests and updates their status |

## 🛠️ Technologies Used
| Area | Technology |
|---|---|
| Front-end | HTML, CSS, JavaScript, Bootstrap 5 |
| Back-end / Database | Supabase (PostgreSQL) |
| Authentication | Supabase Auth |
| Hosting | GitHub Pages |
| Version Control | Git and GitHub |

## ✨ System Features
**Resident**
- Register and log in
- Submit a service request (auto-categorized)
- View own requests with status
- Edit or cancel requests while still *Pending*

**Barangay Staff (Admin)**
- View all requests with resident names
- Search by name, title, or description
- Filter by category and status
- Update status: *Pending → In Progress → Resolved*
- Delete spam requests
- Summary cards and **AI Insights** (most reported concerns)

**AI-Assisted Feature**
- **Auto-classification:** a keyword-based classifier sorts each request into a category (Streetlight / Electrical, Garbage / Sanitation, Road / Infrastructure, Water Supply, Peace and Order, Documents / Certificates, Health, Others). Supports English and Filipino keywords.
- **Insights:** analyzes all requests to show the most reported concern, its percentage, and how many still need action.

## 🏗️ System Architecture
```
[ Browser (HTML, CSS, JS, Bootstrap) ]
              │  hosted on GitHub Pages
              ▼
[ Supabase JavaScript Client ]
              │  HTTPS
              ▼
[ Supabase ]
   ├── Auth (login, hashed passwords)
   └── PostgreSQL Database
        ├── profiles
        └── requests   (protected by Row Level Security)
```

## 🗄️ Database Design
**profiles**
| Column | Type | Description |
|---|---|---|
| id | uuid (PK, FK → auth.users) | User ID |
| full_name | text | Resident's name |
| role | text | `resident` or `admin` |
| created_at | timestamptz | Date registered |

**requests**
| Column | Type | Description |
|---|---|---|
| id | bigint (PK) | Request ID |
| user_id | uuid (FK → profiles) | Who submitted it |
| title | text | 5–100 characters |
| description | text | 10–1000 characters |
| category | text | Auto-detected category |
| status | text | Pending / In Progress / Resolved |
| created_at | timestamptz | Date submitted |

**Relationship:** one profile → many requests (one-to-many).
Full SQL: [`database/schema.sql`](database/schema.sql)

## 🔐 Security
- **Row Level Security (RLS):** residents can only view and edit their own requests; only admins can view all requests and change their status
- **Password hashing** handled by Supabase Auth
- **No admin sign-up:** all new accounts are residents; admins can only be assigned in the database
- **XSS protection:** user input is escaped before it is displayed
- **Validation** on both the form (JavaScript) and the database (`check` constraints)
- Only the public (anon) key is used in the front-end; the secret key is never exposed

## 📸 Screenshots
| Login | Register Validation |
|---|---|
| ![Login](https://github.com/Liporada-Rizza/barangay-service-request/blob/main/SSC/login.png)| ![Register Validation](https://github.com/Liporada-Rizza/barangay-service-request/blob/main/SSC/register-validation.png) |

| Resident Dashboard | Edit Request |
|---|---|
| ![Resident Dashboard](https://github.com/Liporada-Rizza/barangay-service-request/blob/main/SSC/resident-dashboard.png) | ![Edit Request](https://github.com/Liporada-Rizza/barangay-service-request/blob/main/SSC/edit-request.png) |

| Admin Dashboard | Mobile View |
|---|---|
| ![Admin Dashboard](https://github.com/Liporada-Rizza/barangay-service-request/blob/main/SSC/admin-dashboard.png) | ![Mobile](https://github.com/Liporada-Rizza/barangay-service-request/blob/main/SSC/mobile.jpg) |

## ⚙️ Installation
1. Create a free project on [Supabase](https://supabase.com)
2. Open the **SQL Editor** and run [`database/schema.sql`](database/schema.sql)
3. In **Authentication → Providers → Email**, turn off *Confirm email* (for testing)
4. Download or clone this repository
5. Open `js/supabase.js` and put your own **Project URL** and **anon/publishable key**
6. Open `index.html` in a browser, or host the files on GitHub Pages
7. To create an admin: register an account, then change its `role` to `admin` in the `profiles` table

## 📖 How to Use
**Resident:** Register → Log in → Fill in the request form → Submit → Track the status in "My Requests"
**Admin:** Log in → View the summary and AI Insights → Search or filter requests → Change status or delete

## 🧪 Testing
| # | Test Case | Expected Result | Result |
|---|---|---|---|
| 1 | Register with empty fields | Warning message shown | ✅ Passed |
| 2 | Register with password under 8 characters | Warning message shown | ✅ Passed |
| 3 | Log in with wrong password | "Login failed" message | ✅ Passed |
| 4 | Submit "Walang ilaw yung poste" | Category: Streetlight / Electrical | ✅ Passed |
| 5 | Edit a Pending request | Changes saved | ✅ Passed |
| 6 | Cancel a Pending request | Request removed | ✅ Passed |
| 7 | Resident B views requests | Cannot see Resident A's requests (RLS) | ✅ Passed |
| 8 | Request set to Resolved | Resident sees "Locked," no Edit/Cancel | ✅ Passed |
| 9 | Admin searches "basura" | Only matching requests shown | ✅ Passed |
| 10 | Admin changes status | Status and summary update | ✅ Passed |
| 11 | Open on mobile phone | Layout adjusts and works | ✅ Passed |

## ⚠️ Limitations
- The classifier is keyword-based, so it may miss requests with uncommon words or spelling
- No photo upload for requests yet
- Email confirmation is turned off for testing with sample accounts
- Uses sample data only (no real resident information)
- Free Supabase projects may pause after a period of inactivity

## 🚀 Future Improvements
- Use a machine learning or AI language model for smarter classification
- Allow residents to attach photos of the concern
- Send SMS or email notifications when status changes
- Export reports to Excel or PDF
- Show requests on a map by location

## 👩‍💻 Developer
**Rizza Liporada**
BSIT Student, Datamex College of Saint Adeline
- GitHub: https://github.com/Liporada-Rizza
- LinkedIn: https://www.linkedin.com/in/rizzaliporada/
