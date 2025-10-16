# Brainstorming Session Results

**Session Date:** 2024-05-24
**Facilitator:** Mary (Business Analyst)

## **Executive Summary**

**Topic:** A new feature, "Crews," for the "Journeyman Jobs" Flutter application.

**Session Goals:** To define an actionable user journey for a new collaborative job-hunting feature. The goal was to move from a high-level concept to a detailed, step-by-step plan for the user experience.

**Techniques Used:** A Progressive Flow methodology, incorporating elements of Role Playing and User Journey Mapping.

**Key Themes Identified:**

* **Collaborative Discovery:** Empowering groups of traveling workers to find relevant jobs together.
* **Streamlined Communication:** Providing a central, private hub for groups to discuss opportunities.
* **Individual Empowerment:** Ensuring the collaborative feature enhances, rather than restricts, an individual's ability to apply for jobs.
* **Efficiency & Reusability:** Leveraging existing UI components and application logic to deliver value faster.

### **Technique Session: Progressive User Journey Mapping**

We mapped the entire user journey for the "Crews" feature across five distinct stages.

* **Stage 1: Crew Creation & Invitation**

* **Entry Point:** Users tap a "Crews" icon on the bottom navigation bar to access the "Tailboard" screen.
* **Creation:** A new user is prompted to "Create a Crew" or "Join a Crew." The creator is assigned the "Foreman" role.
* **Data Model:** Creating a crew generates a new document in Firebase with a crew name, timestamp, and a unique ID.
* **Business Rules:**
  * A crew has a maximum of 10 members.
  * A user can be the Foreman of a maximum of 3 crews.
  * Any member can leave a crew at any time.
* **Invitations:** The Foreman uses a contact picker to invite members via in-app notification (for existing users) or an SMS/email link with a quick sign-up flow (for new users).

* **Stage 2: Setting Crew Preferences**

* **UI Flow:** Immediately upon creation, the Foreman is shown a dialog to set the Crew's job preferences. This UI component is reused from the individual user's preference settings.
* **Permissions:** Only the Foreman can set or edit the preferences. This is a critical rule to prevent confusion. A clear way to edit these preferences later must be available on the Tailboard screen.
* **Transparency:** All other crew members can view the preferences in a read-only state. Onboarding tooltips will explain this and other feature mechanics to new members.

* **Stage 3: Job Matching & Notification**

* **The Hub:** The "Tailboard" screen is the central hub for all crew activity, containing four tabs:
  * **Jobs:** Displays jobs that match the Crew's preferences.
  * **Chat:** A private, real-time chat for Crew members only.
  * **Feed:** A global message board for all app users.
  * **Members:** A list of the current Crew's members.
* **Notification:** When a matching job is found, all Crew members receive a push notification. The notification displays a "condensed job card" with key details (title, pay, location).
* **Destination:** Tapping the notification takes the user directly to a detailed job dialog popup, which includes a clear "Apply" button.

* **Stage 4: Group Discussion & Interest Gauging**

* **Insightful Pivot:** We determined that a formal, binding vote could prevent users from getting jobs, defeating the app's purpose. The model was changed to focus on communication and informal polling.
* **Discussion:** The primary forum for discussing a new job is the private "Chat" tab.
* **Gauging Interest:** A non-binding "I'm Interested" button on the job card allows members to quickly signal interest. This is for informational purposes only.
* **Transparency:** All members can see who has expressed interest, helping them coordinate organically.

* **Stage 5: Individual Application with Crew Context**

* **User Empowerment:** Any Crew member can choose to apply for a job at any time, regardless of what others think.
* **Action:** Tapping the "Apply" button on the job detail dialog triggers the **app's existing individual application function**.
* **Conclusion:** The "Crews" feature successfully serves its purpose by facilitating collaborative discovery and communication, leading to an individual, empowered action.

### **Idea Categorization**

* **Immediate Opportunities**

1. **Core Crew Functionality:** Build the creation, invitation, and member management logic for Crews.
2. **Tailboard Hub UI:** Develop the tabbed Tailboard screen as the central point for all Crew interactions.
3. **Preference Sync & Job Matching:** Implement the logic for the Foreman to set preferences and for the backend to match and deliver jobs to the Crew.

* **Future Innovations**

* **Detailed Member Profiles:** Flesh out the "Members" tab to show user profiles, skills, or certifications when a name is tapped.
* **Foreman Tools:** Add special tools for Foremen, such as the ability to pin important messages or jobs.
* **Crew Chat Enhancements:** Add features like threaded replies or reactions to the Crew chat to improve communication.

* **Insights & Learnings**

* **The Critical Pivot:** The most significant insight was realizing a formal voting system was counterproductive. Shifting to an informal, communication-focused model ("Discover together, apply individually") is simpler, safer, and more user-centric.

### **Action Planning: Top 3 Priorities**

1. **#1 Priority: Build the Crew & Tailboard Foundation**
    * **Rationale:** This is the core container for the entire feature. Without the ability to create and manage crews and the central hub to view them, nothing else can function.
    * **Next steps:** Design the UI for the Tailboard screen and the "Create a Crew" flow. Define the Firebase data structure for crews and members.
2. **#2 Priority: Implement Preference & Matching Logic**
    * **Rationale:** This delivers the core value proposition of the feature—proactively finding relevant jobs for the group.
    * **Next steps:** Adapt the existing job preference UI for Crew use. Develop the backend logic to scan for jobs that match a Crew's criteria and trigger notifications.
3. **#3 Priority: Integrate Discussion & Application Flow**
    * **Rationale:** This completes the user journey by providing the communication space and connecting the discovery phase to the existing application logic.
    * **Next steps:** Implement the private chat feature within the Tailboard. Add the non-binding "I'm Interested" poll. Ensure the "Apply" button correctly hooks into the existing individual application function.

---

This document captures our highly productive session. Please review it, and let me know if you have any questions. This provides a very strong foundation for the next steps in your development process.
